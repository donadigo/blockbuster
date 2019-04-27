//
//  Copyright (C) 2017 Adam Bieńkowski
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

namespace Gala.Plugins.Blockbuster.Utils {
    public static unowned Meta.Window? get_meta_for_window (Meta.Screen screen, Wnck.Window target) {
        unowned List<weak Meta.WindowActor>? actors = Meta.Compositor.get_window_actors (screen);
        uint32 xid = (uint32)target.get_xid ();

        foreach (unowned Meta.WindowActor actor in actors) {
            unowned Meta.Window meta_window = actor.get_meta_window ();
            if (meta_window.get_xwindow () == xid) {
                return meta_window;
            }
        }

        return null;
    }

    public static unowned Wnck.Window? get_wnck_for_window (Meta.Window target) {
        return Wnck.Window.@get ((ulong)target.get_xwindow ());
    }

    public static bool get_is_workspace_empty (Meta.Workspace workspace) {
        return get_n_normal_window_workspace (workspace) == 0;
    }

    public static bool wnck_is_normal (Wnck.Window window) {
        return window.get_window_type () == Wnck.WindowType.NORMAL;
    }

    public static bool meta_is_normal (Meta.Window window) {
        return window.get_window_type () == Meta.WindowType.NORMAL ||
            window.get_window_type () == Meta.WindowType.DIALOG ||
            window.get_window_type () == Meta.WindowType.MODAL_DIALOG;
    }

    public static unowned Meta.Workspace? find_closest_non_empty_workspace (int from_index, Meta.Screen screen) {
        unowned Meta.Workspace? closest = null;
        for (int i = from_index; i >= 0; i--) {
            unowned Meta.Workspace? w = screen.get_workspace_by_index (i);
            if (i > 0 && Utils.get_is_workspace_empty (w)) {
                continue;
            }

            closest = w;
            break;
        }

        return closest;
    }

    public static Meta.Workspace? find_empty_workspace (Meta.Screen screen) {
        Meta.Workspace? empty = null;
		screen.get_workspaces ().@foreach ((workspace) => {
			if (empty != null) {
				return;
			}

			if (Utils.get_is_workspace_empty (workspace)) {
				empty = workspace;
			}
        });
        
        return empty;
    }

    public static int get_n_normal_window_workspace (Meta.Workspace workspace) {
        int n = 0;
        workspace.list_windows ().@foreach ((window) => {
            if (meta_is_normal (window)) {
                n++;
            }
        });

        return n;
    }

    public static string? get_desktop_file_for_window (Wnck.Window window) {
		var matcher = Bamf.Matcher.get_default ();
		var app = matcher.get_application_for_xid ((uint32)window.get_xid ());
		if (app == null) {
			return null;
		}

		string desktop_file = Path.get_basename (app.get_desktop_file ());
		return desktop_file;
	}
}