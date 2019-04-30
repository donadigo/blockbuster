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

public class Blockbuster.AppChooser : Gtk.Popover {
    private Gtk.ListBox list;
    private Gtk.SearchEntry search_entry;

    private string[] _existing_ids;
    public string[] existing_ids {
        get {
            return _existing_ids;
        }

        set {
            _existing_ids = value;
            list.invalidate_filter ();
        }
    }

    public signal void app_chosen (AppInfo app_info);

    public AppChooser (Gtk.Widget widget) {
        Object (relative_to: widget);
    }

    construct {
        search_entry = new Gtk.SearchEntry ();
        search_entry.margin_end = 12;
        search_entry.margin_start = 12;
        search_entry.placeholder_text = _("Search Applications");

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.height_request = 200;
        scrolled.width_request = 500;
        scrolled.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;

        list = new Gtk.ListBox ();
        list.expand = true;
        list.set_sort_func (sort_function);
        scrolled.add (list);

        var grid = new Gtk.Grid ();
        grid.margin_bottom = 12;
        grid.margin_top = 12;
        grid.row_spacing = 6;
        grid.attach (search_entry, 0, 0, 1, 1);
        grid.attach (scrolled, 0, 1, 1, 1);

        add (grid);

        search_entry.grab_focus ();
        list.row_activated.connect (on_app_selected);
        search_entry.search_changed.connect (apply_filter);

        apply_filter ();

        foreach (var app_info in AppInfo.get_all ()) {
            if (app_info.should_show ()) {
                append_item_from_app_info (app_info);
            }
        }        
    }

    private void append_item_from_app_info (AppInfo app_info) {
        var app_row = new AppChooserRow (app_info);
        list.prepend (app_row);
    }

    private static int sort_function (Gtk.ListBoxRow list_box_row_1,
                                    Gtk.ListBoxRow list_box_row_2) {
        var row_1 = (AppChooserRow)list_box_row_1.get_child ();
        var row_2 = (AppChooserRow)list_box_row_2.get_child ();

        var name_1 = row_1.app_info.get_name ();
        var name_2 = row_2.app_info.get_name ();

        return name_1.collate (name_2);
    }

    private bool filter_function (Gtk.ListBoxRow list_box_row) {
        var app_row = (AppChooserRow)list_box_row.get_child ();

        if (app_row.app_info.get_id () in existing_ids) {
            return false;
        }

        string query = search_entry.text.down ();
        unowned string? description = app_row.app_info.get_description ();
        return query in app_row.app_info.get_name ().down ()
            || (description != null && query in description.down ());
    }

    private void on_app_selected (Gtk.ListBoxRow list_box_row) {
        var app_row = list_box_row.get_child () as AppChooserRow;
        app_chosen (app_row.app_info);
        hide ();
    }

    private void apply_filter () {
        list.set_filter_func (filter_function);
    }
}