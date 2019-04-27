/*
* Copyright (c) 2013-2017 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Julien Spautz <spautz.julien@gmail.com>
*/

public class Blockbuster.AppRow : Gtk.ListBoxRow {
    public AppInfo app_info { get; construct; }
    public bool maximized {
        get {
            return maximize_button.active;
        }

        set {
            maximize_button.active = value;
        }
    }

    public bool focused {
        get {
            return focus_button.active;
        }

        set {
            focus_button.active = value;
        }
    }


    private Gtk.CheckButton maximize_button;
    private Gtk.CheckButton focus_button;

    public signal void config_changed ();

    public AppRow (AppInfo app_info) {
        Object (app_info: app_info);
    }

    construct {
        var image = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.DIALOG);
        image.pixel_size = 48;

        var app_name = new Gtk.Label (app_info.get_name ());
        app_name.get_style_context ().add_class ("h3");
        app_name.xalign = 0;

        var app_comment = new Gtk.Label (app_info.get_description ());
        app_comment.ellipsize = Pango.EllipsizeMode.END;
        app_comment.hexpand = true;
        app_comment.xalign = 0;

        var check_grid = new Gtk.Grid ();
        check_grid.vexpand = true;
        check_grid.valign = Gtk.Align.CENTER;
        check_grid.row_spacing = 6;
        check_grid.margin_end = 6;

        maximize_button = new Gtk.CheckButton.with_label (_("Maximized"));
        maximize_button.tooltip_text = _("Whether to maximize the application window after launching it");
        maximize_button.notify["active"].connect (() => config_changed ());

        focus_button = new Gtk.CheckButton.with_label (_("Focus"));
        focus_button.tooltip_text = _("Whether opening this application will automatically focus it on another workspace");
        focus_button.notify["active"].connect (() => config_changed ());

        check_grid.attach (maximize_button, 0, 0, 1, 1);
        check_grid.attach (focus_button, 0, 1, 1, 1);

        var main_grid = new Gtk.Grid ();
        main_grid.margin_start = main_grid.margin_top = 12;
        main_grid.margin_bottom = 12;
        main_grid.margin_end = 6;
        main_grid.column_spacing = 12;
        main_grid.attach (image, 0, 0, 1, 2);
        main_grid.attach (app_name, 1, 0, 1, 1);
        main_grid.attach (app_comment, 1, 1, 1, 1);
        main_grid.attach (check_grid, 2, 0, 1, 2);

        add (main_grid);
        show_all ();
    }
}