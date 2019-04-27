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

public class Gala.Plugins.Blockbuster.WindowMovementTracker : Object {
    public weak Meta.Display display { get; construct; }
    public signal void open (Meta.Window window, int x, int y);
    private Meta.Window? current_window;
    private const float TRIGGER_RATIO = 0.98f;

    private static Settings animation_settings;

    private float start_x;
    private float start_y;
    private Meta.MaximizeFlags maximize_flags;

    static construct
    {
        animation_settings = new Settings ("org.pantheon.desktop.gala.animations");
    }

    public WindowMovementTracker (Meta.Display display)
    {
        Object (display: display);
    }

    public void watch ()
    {
        display.grab_op_begin.connect ((screen, window, op) => {
            if (window == null) {
                return;
            }

            current_window = window;

            var actor = (Meta.WindowActor)window.get_compositor_private ();
            start_x = actor.x;
            start_y = actor.y;
            maximize_flags = window.get_maximized ();

            current_window.position_changed.connect (on_position_changed);
        });

        display.grab_op_end.connect ((screen, window, op) => {
            current_window.position_changed.disconnect (on_position_changed);
        });
    }

    public void restore_window_state ()
    {
        var actor = (Meta.WindowActor)current_window.get_compositor_private ();
        current_window.move_frame (false, (int)start_x, (int)start_y);
        if (maximize_flags != 0) {
            int previous = animation_settings.get_int ("snap-duration");
            animation_settings.set_int ("snap-duration", 0);
            current_window.maximize (maximize_flags);
            animation_settings.set_int ("snap-duration", previous);

            // kill_window_effects does not reset the translation
            // and that's the only thing we want to do
            actor.set_translation (0.0f, 0.0f, 0.0f);
        }
    }

    private void on_position_changed (Meta.Window window)
    {
        unowned Meta.Screen screen = window.get_screen ();
        unowned Meta.CursorTracker ct = Meta.CursorTracker.get_for_screen (screen);
        int x, y;
        Clutter.ModifierType type;
        ct.get_pointer (out x, out y, out type);

        int height;
        screen.get_size (null, out height);

        if (y > (float)height * TRIGGER_RATIO) {
            window.position_changed.disconnect (on_position_changed);
            open (window, x, y);
        }
    }
}