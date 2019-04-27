/*
* Copyright (c) 2013-2017 elementary LLC. (https://launchpad.net/switchboard-plug-applications)
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

public class Blockbuster.AppChooserRow : Gtk.Grid {
    public AppInfo app_info { get; construct; }

    public signal void deleted ();

    public AppChooserRow (AppInfo app_info) {
        Object (app_info: app_info);
    }

    construct {
        var image = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.DND);
        image.pixel_size = 32;

        var app_name = new Gtk.Label (app_info.get_display_name ());
        app_name.get_style_context ().add_class ("h3");
        app_name.xalign = 0;
        app_name.ellipsize = Pango.EllipsizeMode.END;

        var app_comment = new Gtk.Label ("<span font_size='small'>" + (app_info.get_description () ?? "") + "</span>");
        app_comment.xalign = 0;
        app_comment.use_markup = true;
        app_comment.ellipsize = Pango.EllipsizeMode.END;

        margin = 6;
        margin_end = 12;
        margin_start = 10; // Account for icon position on the canvas
        column_spacing = 12;
        attach (image, 0, 0, 1, 2);
        attach (app_name, 1, 0, 1, 1);
        attach (app_comment, 1, 1, 1, 1);

        show_all ();
    }
}