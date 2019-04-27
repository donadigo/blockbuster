
//
//  Copyright (C) 2019 Adam Bieńkowski
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

public class Blockbuster.WorkspaceView : Gtk.Grid {
    public const string WORKSPACE_VIEW_ID = "workspaces";
    public const string CONFIG_VIEW_ID = "config";
    private const string WELCOME_VIEW_ID = "welcome";

    private Gee.ArrayList<unowned WorkspaceBox> views;

    public int n_workspaces { get; private set; default = 0; }

    public signal void entered_configuration_view ();

    public Gtk.Stack stack { get; construct; }
    private ConfigurationView conf_view;
    private Gtk.Box box;

    construct {
        views = new Gee.ArrayList<unowned WorkspaceBox> ();

        var welcome = new Granite.Widgets.Welcome (
            _("Configure Workspaces"),
             _("Add new workspaces and configure what applications\nappear on them by default.")
        );

        int button_index = welcome.append ("preferences-desktop-add", _("Add New Workspace"), _("Add a new empty workspace"));
        welcome.activated.connect (on_welcome_activated);
        welcome.get_button_from_index (button_index).icon.use_fallback = false;

        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
        box.margin = 24;
        box.halign = box.valign = Gtk.Align.CENTER;
        box.expand = true;

        conf_view = new ConfigurationView ();

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.add_named (welcome, WELCOME_VIEW_ID);
        stack.add_named (box, WORKSPACE_VIEW_ID);
        stack.add_named (conf_view, CONFIG_VIEW_ID);

        add (stack);

        init_update ();

        PluginSettings.get_default ().bindings_changed.connect (update);
        update ();
    }

    public void add_new_workspace () {
        var ws_box = new WorkspaceBox (n_workspaces++);
        ws_box.button.clicked.connect (() => {
            conf_view.index = ws_box.index;
            stack.set_visible_child_name (CONFIG_VIEW_ID);
            entered_configuration_view ();
        });

        box.add (ws_box);
        box.show_all ();

        views.add (ws_box);
    }

    private void on_welcome_activated (int index) {
        add_new_workspace ();
        stack.set_visible_child_name (WORKSPACE_VIEW_ID);
    }

    private void init_update () {
        var config = PluginSettings.get_default ().get_config ();

        int max = 0;
        foreach (var app_config in config.values) {
			max = int.max (max, app_config.workspace + 1);
        }

        for (int i = 0; i < max; i++) {
            add_new_workspace ();
        }

        n_workspaces = max;
    }

    private void update () {
        var config = PluginSettings.get_default ().get_config ();

        var workspace_map = new Gee.HashMap<int, Gee.ArrayList<string>> ();

        // Transform <app-id, AppConfig> to <workspace-id, app-id>
        foreach (var entry in config.entries) {
            var app_config = entry.value;
            if (workspace_map.has_key (app_config.workspace)) {
                workspace_map[app_config.workspace].add (entry.key);
            } else {
                workspace_map[app_config.workspace] = new Gee.ArrayList<string> ();
                workspace_map[app_config.workspace].add (entry.key);
            }
        }

        foreach (var view in views) {
            if (workspace_map.has_key (view.index)) {
                view.button.set_displayed_ids (workspace_map[view.index]);
            } else {
                view.button.set_displayed_ids (null);
            }
        }
    }
}