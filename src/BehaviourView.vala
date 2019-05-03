
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

public class Blockbuster.BehaviourView : Gtk.Box {
    private Gtk.ListBox list_box;

    construct {
        var return_on_empty = new SettingRow (
            _("Switch to previous workspace if current is empty"),
            _("Closing the last window on a workspace will automatically remove the current workspace and switch to the previous one"),
            "return-workspace-on-empty"
        );

        var switch_on_maximize = new SettingRow (
            _("Switch to a new workspace when a window is maximized "),
            _("Maximizing a window will automatically create a new workspace and move to it with the maximized window"),
            "switch-workspace-on-maximize"
        );

        var snap_to_bottom = new SettingRow (
            _("Snap a window to bottom to open mutltiasking view"),
            _("Dragging a window to the bottom of the screen will open the multitasking view with the selected window"),
            "snap-to-bottom"
        );

        list_box = new Gtk.ListBox ();
        list_box.get_style_context ().add_class ("settings-list");
        list_box.selection_mode = Gtk.SelectionMode.NONE;
        list_box.add (return_on_empty);
        list_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        list_box.add (switch_on_maximize);
        list_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        list_box.add (snap_to_bottom);
        list_box.show_all ();
        add (list_box);

    }
}