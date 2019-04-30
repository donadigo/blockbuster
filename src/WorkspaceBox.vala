
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

public class Blockbuster.WorkspaceBox : Gtk.EventBox {
    public WorkspaceButton button { get; construct; }
    public int index { get; construct set; }

    public signal void removed ();
    public signal void clear_all ();

    private Gtk.Label label;
    private Gtk.Button remove_button;

    construct {
        tooltip_text = _("Configure workspace %i…").printf (index + 1);
        
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

        button = new WorkspaceButton ();
        button.removed.connect (() => removed ());
        button.clear_all.connect (() => clear_all ());
        button.enter_notify_event.connect (() => {
            remove_button.opacity = 1;
            return false;
        });        

        main_box.add (button);

        label = new Gtk.Label (null);
        label.label = _("Workspace %i").printf (index + 1);
        label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        remove_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        remove_button.tooltip_text = _("Remove this workspace");
        remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        remove_button.halign = Gtk.Align.END;
        remove_button.opacity = 0;
        remove_button.clicked.connect (() => removed ());
        remove_button.enter_notify_event.connect (() => {
            remove_button.opacity = 1;
            return false;
        });

        var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        bottom_box.set_center_widget (label);
        bottom_box.pack_end (remove_button);
        main_box.add (bottom_box);

        add (main_box);
    }

    public WorkspaceBox (int index) {
        Object (index: index);
    }

    protected override bool enter_notify_event (Gdk.EventCrossing event) {
        remove_button.opacity = 1;
        return false;
    }

    protected override bool leave_notify_event (Gdk.EventCrossing event) {
        remove_button.opacity = 0;
        return false;
    }
}