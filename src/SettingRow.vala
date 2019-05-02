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

using Blockbuster.Common;

public class Blockbuster.SettingRow : Gtk.ListBoxRow {
    public string label { get; construct; }
    public string description { get; construct; }
    public string setting_id { get; construct; }

    private Gtk.Switch sw;

    construct {
        var app_name = new Gtk.Label (label);
        app_name.get_style_context ().add_class ("h3");
        app_name.xalign = 0;

        var app_comment = new Gtk.Label (description);
        app_comment.opacity = 0.7;
        app_comment.wrap = true;
        app_comment.wrap_mode = Pango.WrapMode.WORD_CHAR;
        app_comment.ellipsize = Pango.EllipsizeMode.END;
        app_comment.hexpand = true;
        app_comment.xalign = 0;

        sw = new Gtk.Switch ();
        sw.valign = Gtk.Align.CENTER;
        PluginSettings.get_default ().schema.bind (setting_id, sw, "active", SettingsBindFlags.DEFAULT);

        var main_grid = new Gtk.Grid ();
        main_grid.margin_start = main_grid.margin_end = 12;
        main_grid.margin_top = main_grid.margin_bottom = 12;
        main_grid.column_spacing = 12;
        main_grid.attach (app_name, 0, 0, 1, 1);
        main_grid.attach (app_comment, 0, 1, 1, 1);
        main_grid.attach (sw, 1, 0, 1, 2);

        var event_box = new Gtk.EventBox ();
        event_box.add (main_grid);

        add (event_box);
        show_all ();
    }

    public SettingRow (string label, string description, string setting_id) {
        Object (label: label, description: description, setting_id: setting_id);
    }

    public override bool button_release_event (Gdk.EventButton e) {
        if (e.window == sw.get_window () && e.button == Gdk.BUTTON_PRIMARY) {
            sw.active = !sw.active;
        }

        return base.button_release_event (e);
    }
}