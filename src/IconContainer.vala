
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

public class Blockbuster.IconContainer : Gtk.Box {
    private const int MAX_ICONS = 3;
    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;
    }

    private void clear () {
        foreach (var child in get_children ()) {
            child.destroy ();
        }
    }

    public void set_displayed_ids (Gee.ArrayList<string> ids) {
        clear ();

        int m = int.min (MAX_ICONS, ids.size);
        foreach (string id in ids) {
            var app_info = new DesktopAppInfo (id);
            
            var image = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.DND);
            image.pixel_size = 48;
            image.show_all ();
            add (image);
        }
    }
}