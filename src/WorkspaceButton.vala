
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

public class Blockbuster.WorkspaceButton : Gtk.Button {
    private const int DOCK_WIDTH = 120;
    private const int DOCK_HEIGHT = 13;
    private const int DOCK_RADIUS = 5;

    private const int PANEL_HEIGHT = 10;
    private const int PLUS_SIZE = 70;
    private const int PLUS_WIDTH = 10;

    private const Gdk.RGBA OVERLAY_COLOR = { 61 / 255.0, 75 / 255.0, 122 / 255.0, 1.0 };

    private IconContainer icon_container;

    construct {
        icon_container = new IconContainer ();

        get_style_context ().add_class ("workspace-box");

        set_size_request (300, 200);
    }

    
    public WorkspaceButton () {
        image = new Gtk.Image.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.DND);
    }

    public void set_displayed_ids (Gee.ArrayList<string>? ids) {
        if (ids == null) {
            image = new Gtk.Image.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.DND);
        } else {
            icon_container.set_displayed_ids (ids);
            image = icon_container;
        }
    }

    public override bool draw (Cairo.Context cr) {
        Gtk.Allocation alloc;
        get_allocated_size (out alloc, null);
        cr.set_source_rgba (OVERLAY_COLOR.red, OVERLAY_COLOR.green, OVERLAY_COLOR.blue, OVERLAY_COLOR.alpha);
        
        base.draw (cr);
        // The clip
        Granite.Drawing.Utilities.cairo_rounded_rectangle (
            cr, 0, 0, alloc.width, alloc.height,
            5
        );
        cr.clip ();

        cr.set_line_width (4);
        Granite.Drawing.Utilities.cairo_rounded_rectangle (
            cr, 0, 0, alloc.width, alloc.height,
            5
        );
        cr.stroke ();

        // Panel
        cr.rectangle (0, 0, alloc.width, PANEL_HEIGHT);
        cr.fill ();

        // Dock
        Granite.Drawing.Utilities.cairo_rounded_rectangle (
            cr, (alloc.width - DOCK_WIDTH) / 2, alloc.height - DOCK_HEIGHT,
            DOCK_WIDTH, DOCK_HEIGHT + DOCK_RADIUS, 
            DOCK_RADIUS
        );

        cr.fill ();

        // The plus
        //  cr.rectangle (
        //      alloc.width / 2 - PLUS_SIZE / 2,
        //      alloc.height / 2 - PLUS_WIDTH / 2,
        //      PLUS_SIZE, PLUS_WIDTH
        //  );
        //  cr.fill ();

        //  cr.rectangle (
        //      alloc.width / 2 - PLUS_WIDTH / 2,
        //      alloc.height / 2 - PLUS_SIZE / 2,
        //      PLUS_WIDTH, PLUS_SIZE
        //  );
        //  cr.fill ();


        //  get_style_context ().render_background (cr, 0, 0, alloc.width, alloc.height);

        return true;
    }
}