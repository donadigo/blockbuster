
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

public class Blockbuster.ConfigurationView : Gtk.Grid {
    private int _index = 0;
    public int index {
        get {
            return _index;
        }

        set {
            _index = value;
            update ();
        }
    }

    private Gtk.ListBox list;
    private AppChooser app_chooser;

    private Gtk.ScrolledWindow scrolled;
    private Gtk.ToolButton remove_button;

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        list = new Gtk.ListBox ();
        list.expand = true;
        list.row_selected.connect (on_row_selected);

        var empty_alert = new Granite.Widgets.AlertView (_("Set What Apps Appear on This Workspace"), _("Add default apps to the workspace by clicking the icon in the toolbar below."), "window-new");
        empty_alert.show_all ();     
        list.set_placeholder (empty_alert);

        scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (list);

        var frame = new Gtk.Frame (null);
        frame.add (scrolled);

        var toolbar = new Gtk.Toolbar ();
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        toolbar.icon_size = Gtk.IconSize.SMALL_TOOLBAR;

        var add_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("application-add-symbolic", Gtk.IconSize.BUTTON), null);
        add_button.tooltip_text = _("Add Default App…");
        add_button.clicked.connect (() => {app_chooser.show_all ();});

        remove_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON), null);
        remove_button.tooltip_text = _("Remove Default App");
        remove_button.clicked.connect (on_remove_button_clicked);
        remove_button.sensitive = false;

        toolbar.add (add_button);
        toolbar.add (remove_button);

        app_chooser = new AppChooser (add_button);
        app_chooser.modal = true;
        app_chooser.init_list ();

        add (frame);
        add (toolbar);

        app_chooser.app_chosen.connect (on_app_added);
        update ();
    }

    private void on_row_selected (Gtk.ListBoxRow? row) {
        remove_button.sensitive = row != null;
    }

    private void on_remove_button_clicked () {
        var selected = list.get_selected_row ();
        if (selected != null) {
            var neighbor = list.get_row_at_index (selected.get_index () - 1);
            if (neighbor != null) {
                list.select_row (neighbor);
            } else {
                neighbor = list.get_row_at_index (selected.get_index () + 1);
                list.select_row (neighbor);
            }

            list.remove (selected);
            update_settings ();
        }
    }

    private void on_app_added (AppInfo app_info) {
        var row = new AppRow (app_info);
        row.config_changed.connect (update_settings);
        list.add (row);
        list.show_all ();

        update_settings ();
    }

    private void update () {
        foreach (var row in list.get_children ()) {
            row.destroy ();
        }

        var config = PluginSettings.get_default ().get_config ();
        foreach (var entry in config.entries) {
            var app_config = entry.value;
            if (app_config.workspace != index) {
                continue;
            }

            var app_info = new DesktopAppInfo (entry.key);
            var row = new AppRow (app_info);
            row.maximized = app_config.maximize;
            row.focused = app_config.focus;
            row.config_changed.connect (update_settings);
            list.add (row);
            list.show_all ();
        }
    }

    private void update_settings () {
        unowned PluginSettings settings = PluginSettings.get_default ();
        var config = settings.get_config ({ index });

        foreach (var child in list.get_children ()) {
            var row = (AppRow)child;

            var app_config = new AppConfig (index, row.maximized, row.focused);
            config[row.app_info.get_id ()] = app_config;
        }

        settings.set_config (config);
    }
}