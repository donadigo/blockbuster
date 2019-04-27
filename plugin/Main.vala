//
//  Copyright (C) 2017 Adam Bieńkowski
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Blockbuster.Common;

public class Gala.Plugins.Blockbuster.Main : Gala.Plugin {
	Gala.WindowManager? wm = null;

	Gee.LinkedList<unowned Meta.Window> dirty_windows;
	Gee.HashMap<unowned Meta.Window, int> window_owners;

	WindowMovementTracker tracker;

	delegate bool IterateCallback<T> (T actor);

	public override void initialize (Gala.WindowManager wm) {
		this.wm = wm;

		PluginSettings.get_default ().schema.changed.connect (on_settings_changed);

		dirty_windows = new Gee.LinkedList<unowned Meta.Window> ();
		window_owners = new Gee.HashMap<unowned Meta.Window, int> ();

		/**
		 * Using the Meta.Display.window_created signal doesn't work
		 * here because we want Bamf to actually update it's own list of
		 * windows from Wnck to recognize what application owns the window
		 * Bamf.Matcher.view_* signals also don't work here.
		 */
		var screen = Wnck.Screen.@get (wm.get_screen ().get_screen_number ());
		screen.window_opened.connect (on_wnck_window_opened);
		screen.window_closed.connect (on_wnck_window_closed);

		tracker = new WindowMovementTracker (wm.get_screen ().get_display ());
		tracker.open.connect (open_multitasking_view);
		update_tracker ();
	}

	void open_multitasking_view (Meta.Window window, int x, int y)
	{
		var multitasking_view = get_multitasking_view ();
		if (multitasking_view == null) {
			return;
		}

		unowned Meta.Display display = wm.get_screen ().get_display ();
		display.end_grab_op (display.get_current_time ());

		multitasking_view.open (null);

		Gala.WindowClone? window_clone = null;
		/**
		 * We stream the results from an iterator to be more efficient
		 * at checking which actor contains the target window
		 */
		get_workspace_clones ((Clutter.Actor)multitasking_view, (ws_clone) => {
			get_window_clones (ws_clone, (wc) => {
				if (wc.window == window) {
					window_clone = wc; 
					return true;
				}

				return false;
			});

			return window_clone != null;
		});

		Clutter.Clone? texture = null;
		foreach (var actor in window_clone.get_children ()) {
			if (actor.get_type ().name () == "ClutterClone") {
				texture = (Clutter.Clone)actor;
				break;
			}
		}

		texture.opacity = 0;
		emit_drag_event (window_clone);

		Idle.add (() => {
			tracker.restore_window_state ();
			return false;
		});		
	}

	static void emit_drag_event (Clutter.Actor actor)
	{
		var click_event = new Clutter.Event (Clutter.EventType.BUTTON_PRESS);
		click_event.set_time (Gdk.CURRENT_TIME);
		click_event.set_button (1);

		var threshold = Clutter.Settings.get_default ().dnd_drag_threshold;
		click_event.set_coords (-threshold-1, -threshold-1);
		actor.button_press_event ((Clutter.ButtonEvent)click_event);
		
		var motion_event = new Clutter.Event (Clutter.EventType.MOTION);
		motion_event.set_coords (0, 0);

		var stage = actor.get_stage ();
		stage.captured_event (motion_event);
	}

	ActivatableComponent? get_multitasking_view ()
	{
		foreach (var actor in wm.ui_group.get_children ()) {
			if (actor.get_type ().name () == "GalaMultitaskingView") {
				return ((ActivatableComponent)actor);
			}
		}

		return null;
	}

	static void get_workspace_clones (Clutter.Actor multitasking_view, IterateCallback<Gala.WorkspaceClone> cb)
	{
		foreach (var actor in multitasking_view.get_children ()) {
			foreach (var a in actor.get_children ()) {
				if (a.get_type ().name () == "GalaWorkspaceClone") {
					if (cb ((Gala.WorkspaceClone)a)) {
						return;
					}
				}
			}
		}
	}
	
	static void get_window_clones (Gala.WorkspaceClone ws_clone, IterateCallback<Gala.WindowClone> cb)
	{
		foreach (var actor in ws_clone.window_container.get_children ()) {
			if (actor.get_type ().name () == "GalaWindowClone") {
				if (cb ((Gala.WindowClone)actor)) {
					return;
				}
			}
		}
	}

	public override void destroy ()
	{
		dirty_windows.clear ();
		window_owners.clear ();
	}

	void on_settings_changed (string key) {
		switch (key) {
			case "app-workspace-bindings":
				PluginSettings.get_default ().force_update_config ();
				break;
			case "snap-to-bottom":
				update_tracker ();
				break;
			default:
				break;
		}
	}

	void update_tracker ()
	{
		if (PluginSettings.get_default ().schema.get_boolean ("snap-to-bottom")) {
			tracker.watch ();
		} else {
			tracker.unwatch ();
		}
	}

	void on_maximized_vertically_changed (Meta.Window window) {
		if (!PluginSettings.get_default ().schema.get_boolean ("switch-workspace-on-maximize") ||
			!window.maximized_vertically ||
			window in dirty_windows ||
			is_on_dedicated_workspace (window) ||
			Utils.get_n_normal_window_workspace (window.get_workspace ()) == 1) {
			return;
		}

		var screen = wm.get_screen ();
		var workspace = Utils.find_empty_workspace (screen);
		if (workspace == null) {
			workspace = screen.append_new_workspace (false, screen.get_display ().get_current_time ());
		}

		if (workspace != null) {
			window_owners[window] = window.get_workspace ().index ();
			window.change_workspace (workspace);
			switch_workspace_focus (window, workspace);
		}
	}

	void on_wnck_window_opened (Wnck.Window window) {
		unowned Meta.Window? mwin = process_wnck_window (window);
		if (mwin != null) {
			watch_meta_window (mwin);
		}
	}

	unowned Meta.Window? process_wnck_window (Wnck.Window window) {
		// TODO: if the app is not already opened, consider processing dialog windows
		if (!Utils.wnck_is_normal (window)) {
			return null;
		}

		var screen = wm.get_screen ();
		unowned Meta.Window? mwin = Utils.get_meta_for_window (screen, window);
		if (mwin == null) {
			return null;
		}

		string? desktop_file = Utils.get_desktop_file_for_window (window);
		if (desktop_file == null) {
			return mwin;
		}

		var workspace_bindings = PluginSettings.get_default ().config;
		if (!workspace_bindings.has_key (desktop_file)) {
			return mwin;
		}

		var config = workspace_bindings[desktop_file];
		int workspace_idx = config.workspace;

		if (window.get_workspace ().get_number () == workspace_idx) {
			return mwin;
		}

		bool append = screen.get_workspace_by_index (workspace_idx) == null;
		mwin.change_workspace_by_index (workspace_idx, append);

		dirty_windows.add (mwin);

		/**
		 * Since the window can be maximized when switching to a workspace
		 * we need to prevent the on_maximized_vertically_changed method
		 * to switch to any other workspace while the window is being maximized.
		 *
		 * This method is called here after adding the window to the "dirty windows" list
		 * to prevent that.
		 */
		watch_meta_window (mwin);

		if (config.maximize) {
			if (mwin.can_maximize ()) {
				mwin.maximize (Meta.MaximizeFlags.BOTH);
			}
		} else if (mwin.maximized_vertically || mwin.maximized_horizontally) { // If the app remembered previous maximized state, unmaximize
			mwin.unmaximize (Meta.MaximizeFlags.BOTH);
		}

		if (config.focus) {
			unowned Meta.Workspace? workspace = screen.get_workspace_by_index (workspace_idx);
			if (workspace != null) {
				switch_workspace_focus (mwin, workspace);
			}
		}

		dirty_windows.remove (mwin);

		// We've already set up a watch for the meta window
		return null;
	}

	void on_wnck_window_closed (Wnck.Window window) {
		var screen = wm.get_screen ();
		if (window.get_workspace () == null) {
			return;
		}

		unowned Meta.Workspace? workspace = screen.get_workspace_by_index (window.get_workspace ().get_number ());
		if (workspace == null) {
			return;
		}

		int current_idx = workspace.index ();
		if (!PluginSettings.get_default ().schema.get_boolean ("return-workspace-on-empty") ||
			!Utils.get_is_workspace_empty (workspace) ||
			current_idx <= 0 ||
			current_idx != screen.get_active_workspace_index ()) {
			return;
		}

		unowned Meta.Workspace? previous = null;

		unowned Meta.Window? mwin = Utils.get_meta_for_window (screen, window);
		if (mwin != null && window_owners.has_key (mwin)) {
			int prev_index = window_owners[mwin];
			previous = screen.get_workspace_by_index (prev_index);
			window_owners.unset (mwin);
		} else {
			previous = Utils.find_closest_non_empty_workspace (current_idx, screen);
		}

		if (previous != null) {
			previous.activate (screen.get_display ().get_current_time ());
		}
	}

	void watch_meta_window (Meta.Window window) {
		ulong notify_id = window.notify["maximized-vertically"].connect (() => on_maximized_vertically_changed (window));
		on_maximized_vertically_changed (window);

		window.unmanaged.connect (() => {
			if (window in dirty_windows) {
				dirty_windows.remove (window);
			}

			window.disconnect (notify_id);
		});
	}

	void switch_workspace_focus (Meta.Window window, Meta.Workspace workspace) {
		/**
		 * Workaround the current bug with switching
		 * workspaces when a window is animating causing
		 * damaged surface
		 */
		window.minimize ();
		workspace.activate_with_focus (window, wm.get_screen ().get_display ().get_current_time ());
		window.unminimize ();
	}

	bool is_on_dedicated_workspace (Meta.Window window) {
		unowned Wnck.Window? wnck_window = Utils.get_wnck_for_window (window);
		if (wnck_window == null) {
			return false;
		}

		string? desktop_file = Utils.get_desktop_file_for_window (wnck_window);
		if (desktop_file == null) {
			return false;
		}

		var workspace_bindings = PluginSettings.get_default ().config;
		var config = workspace_bindings[desktop_file];
		return config.workspace == window.get_workspace ().index ();
	}
}

public Gala.PluginInfo register_plugin () {
	return {
		"Blockbuster",                    // the plugin's name
		"Adam Bieńkowski <donadigos159@gmail.com>", // you, the author
		typeof (Gala.Plugins.Blockbuster.Main),  // the type of your plugin class

		Gala.PluginFunction.ADDITION,         // the function which your plugin
		                                      // fulfils, ADDITION means nothing
		                                      // specific

		Gala.LoadPriority.IMMEDIATE           // indicates whether your plugin's
		                                      // start can be delayed until gala
		                                      // has loaded the important stuff or
		                                      // if you want your plugin to start
		                                      // right away. False means wait.
	};
}
