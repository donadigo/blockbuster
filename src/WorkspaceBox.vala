
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

public class Blockbuster.WorkspaceBox : Gtk.Box {
    public WorkspaceButton button { get; construct; }
    public int index { get; construct; }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 12;

        button = new WorkspaceButton ();
        add (button);

        var label = new Gtk.Label (_("Workspace %i").printf (index + 1));
        label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
        add (label);

        tooltip_text = _("Configure workspace %i…").printf (index + 1);
    }

    public WorkspaceBox (int index) {
        Object (index: index);
    }
}