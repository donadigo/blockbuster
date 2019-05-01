
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

public enum Blockbuster.UndoAction {
    REMOVE,
    CLEAR_ALL
}

public class Blockbuster.WorkspaceView : Gtk.Overlay {
    public const string WORKSPACE_VIEW_ID = "workspaces";
    public const string CONFIG_VIEW_ID = "config";
    private const string WELCOME_VIEW_ID = "welcome";
    private const int MAX_COLUMNS = 3;

    public uint n_workspaces { 
        get {
            return grid.get_children ().length ();
        }
    }

    public signal void entered_configuration_view ();
    public signal void update_window ();

    public Gtk.Stack stack { get; construct; }
    private ConfigurationView conf_view;
    private Gtk.Grid grid;
    private Granite.Widgets.Toast toast;

    private UndoAction current_action;

    construct {
        var welcome = new Granite.Widgets.Welcome (
            _("Configure Workspaces"),
             _("Add new workspaces and configure what applications\nappear on them by default.")
        );

        int button_index = welcome.append ("preferences-desktop-add", _("Add New Workspace"), _("Add a new empty workspace"));
        welcome.activated.connect (on_welcome_activated);
        welcome.get_button_from_index (button_index).icon.use_fallback = false;
        welcome.show_all ();

        grid = new Gtk.Grid ();
        grid.column_spacing = 18;
        grid.row_spacing = 18;

        grid.margin = 24;
        grid.halign = grid.valign = Gtk.Align.CENTER;
        grid.expand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        scrolled.add (grid);
        scrolled.show_all ();

        conf_view = new ConfigurationView ();
        conf_view.updated.connect (update);

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.add_named (welcome, WELCOME_VIEW_ID);
        stack.add_named (scrolled, WORKSPACE_VIEW_ID);
        stack.add_named (conf_view, CONFIG_VIEW_ID);

        add (stack);

        toast = new Granite.Widgets.Toast ("");
        toast.set_default_action (_("Undo"));
        toast.default_action.connect (on_restore_config);
        toast.show_all ();

        add_overlay (toast);

        init_update ();
    }

    public void add_new_workspace () {
        int n_children = (int)grid.get_children ().length ();

        var ws_box = new WorkspaceBox (n_children);
        ws_box.button.clicked.connect (() => enter_configuration_view (ws_box));
        ws_box.removed.connect (on_removed_workspace);
        ws_box.clear_all.connect (on_clear_all_workspace);

        int row, column;
        calculate_next_position (n_children, out row, out column);
        grid.attach (ws_box, column, row, 1, 1);
        grid.show_all ();

        update_window ();
        notify_property ("n-workspaces");
    }

    private static void calculate_next_position (int n_children, out int row, out int column) {
        row = (int)(n_children / MAX_COLUMNS);
        column = n_children % MAX_COLUMNS;
    }

    private void enter_configuration_view (WorkspaceBox ws_box) {
        conf_view.index = ws_box.index;
        stack.set_visible_child_name (CONFIG_VIEW_ID);
        entered_configuration_view ();
    }

    private void on_removed_workspace (WorkspaceBox ws_box) {
        unowned PluginSettings settings = PluginSettings.get_default ();

        toast.title = _("Workspace %i removed".printf (ws_box.index + 1));

        reset_grid (n_workspaces - 1);

        settings.save_config_variant ();
        settings.apply_remove_workspace (ws_box.index);
        update ();

        current_action = UndoAction.REMOVE;
        toast.send_notification ();

        notify_property ("n-workspaces");
    }

    private void on_clear_all_workspace (WorkspaceBox ws_box) {
        unowned PluginSettings settings = PluginSettings.get_default ();
        
        toast.title = _("Apps cleared");
        
        settings.save_config_variant ();
        var new_config = settings.filter_config (ws_box.index);
        settings.apply_config (new_config);
        update ();

        current_action = UndoAction.CLEAR_ALL;
        toast.send_notification ();

        notify_property ("n-workspaces");
    }

    private void on_restore_config () {
        uint diff = current_action == UndoAction.REMOVE ? 1 : 0;
        reset_grid (n_workspaces + diff);

        PluginSettings.get_default ().restore_config_variant ();
        update ();

        notify_property ("n-workspaces");
    }

    private void on_welcome_activated (int index) {
        add_new_workspace ();
        update ();
    }

    private void reset_grid (uint n_workspaces) {
        List<weak Gtk.Widget> children = grid.get_children ();
        foreach (weak Gtk.Widget child in children) {
            child.destroy ();
        }

        for (int i = 0; i < n_workspaces; i++) {
            add_new_workspace ();
        }
    }

    private void init_update () {
        var config = PluginSettings.get_default ().config;
        var last_workspace = config.max ((a, b) => {
            return a.value.workspace > b.value.workspace ? -1 : 1;
        });

        if (last_workspace != null) {
            int max = last_workspace.value.workspace + 1;
            
            for (int i = 0; i < max; i++) {
                add_new_workspace ();
            }
        }

        update ();
    }

    private void update () {
        if (stack.visible_child_name != CONFIG_VIEW_ID) {
            if (n_workspaces == 0) {
                stack.visible_child_name = WELCOME_VIEW_ID;
                return;
            } else {
                stack.visible_child_name = WORKSPACE_VIEW_ID;
            }
        }

        var config = PluginSettings.get_default ().config;
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

        foreach (weak Gtk.Widget child in grid.get_children ()) {
            var view = (WorkspaceBox)child;
            if (workspace_map.has_key (view.index)) {
                view.button.set_displayed_ids (workspace_map[view.index]);
            } else {
                view.button.set_displayed_ids (null);
            }
        }

        update_window ();
    }
}