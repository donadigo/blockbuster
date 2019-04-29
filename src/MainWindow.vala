
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

public static void set_widget_visible (Gtk.Widget widget, bool visible) {
    widget.no_show_all = !visible;
    widget.visible = visible;
}

public class Blockbuster.MainWindow : Gtk.Window {
    private const string WORKSPACE_VIEW_ID = "workspaces";
    private const string BEHAVIOUR_VIEW_ID = "behaviour";

    private Gtk.Stack stack;
    private WorkspaceView workspace_view;
    private Gtk.Button back_button;
    private Gtk.Button add_button;

    construct {
        title = "Blockbuster";
        set_size_request (800, 600);

        workspace_view = new WorkspaceView ();
        workspace_view.notify["n-workspaces"].connect (update_header_bar);
        workspace_view.entered_configuration_view.connect (on_entered_configuration_view);

        /**
         * We use this hack to workaround an issue where the window contents
         * would not update after e.g removal of a workspace
         */
        workspace_view.update_window.connect (() => queue_resize ());

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.notify["visible-child-name"].connect (update_header_bar);
        stack.add_titled (workspace_view, WORKSPACE_VIEW_ID, _("Applications"));
        stack.add_titled (new Gtk.Grid (), BEHAVIOUR_VIEW_ID, _("Behaviour"));

        var switcher = new Gtk.StackSwitcher ();
        switcher.set_stack (stack);

        var header_bar = new Gtk.HeaderBar ();
        header_bar.show_close_button = true;
        header_bar.set_custom_title (switcher);

        set_titlebar (header_bar);

        back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        back_button.tooltip_text = _("Go back");
        back_button.clicked.connect (on_back_button_clicked);
        header_bar.pack_start (back_button);
        set_widget_visible (back_button, false);

        add_button = new Gtk.Button.from_icon_name ("preferences-desktop-add", Gtk.IconSize.LARGE_TOOLBAR);
        add_button.clicked.connect (workspace_view.add_new_workspace);
        add_button.tooltip_text = _("Add new workspace");
        header_bar.pack_start (add_button);

        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("com/github/donadigo/blockbuster/application.css");
        Gtk.StyleContext.add_provider_for_screen (get_screen (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        add (stack);

        update_header_bar ();
    }

    private void on_entered_configuration_view () {
        set_widget_visible (back_button, true);
    }

    private void on_back_button_clicked () {
        workspace_view.stack.visible_child_name = WORKSPACE_VIEW_ID;
        set_widget_visible (back_button, false);
    }

    private void update_header_bar () {
        add_button.opacity = (workspace_view.n_workspaces > 0 && stack.visible_child_name == WORKSPACE_VIEW_ID) ? 1.0 : 0;
        set_widget_visible (
            back_button, stack.visible_child_name == WORKSPACE_VIEW_ID &&
            workspace_view.stack.visible_child_name == WorkspaceView.CONFIG_VIEW_ID
        );
    }
}