
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

public class Blockbuster.Common.PluginSettings : Object {
    private static PluginSettings? instance;
    public static unowned PluginSettings get_default () {
        if (instance == null) {
            instance = new PluginSettings ();
        }

        return instance;
    }

    public Gee.HashMap<string, AppConfig> config { get; private set; }

    public Settings schema { get; construct; }
    public signal void bindings_changed ();

    construct {
        schema = new Settings ("com.github.donadigo.blockbuster.plugin");
        schema.changed.connect ((key) => {
            if (key == "app-workspace-bindings") {
                bindings_changed ();
            }
        });
    }

    protected PluginSettings () {
        config = new Gee.HashMap<string, AppConfig> ();
        force_update_config ();
    }

    /**
     * We have two modes in which PluginSettings can work:
     * 1. A "lazy" mode which is used by the UI. In this mode
     * we do not listen for setting changes at all and only update
     * the internal config when the user actually changes something
     * in the UI. This allows us to query the bindings key
     * only once at startup.
     * 
     * 2. A "listen" mode which is used by the plugin. In this mode
     * the plugin calls this method to forcefully update the config
     * when the settings change (possibly emitted by the UI).
     */
    public void force_update_config () {
        config.clear ();

        var val = schema.get_value ("app-workspace-bindings");
        for (int i = 0; i < val.n_children (); i++) {
			var child = val.get_child_value (i);
			if (child.n_children () < 4) {
				continue;
            }
            
            int workspace_id = child.get_child_value (1).get_int32 ();

			string app_id = child.get_child_value (0).get_string ();
			bool maximize = child.get_child_value (2).get_boolean ();
            bool focus = child.get_child_value (3).get_boolean ();
            
            var app_config = new AppConfig (workspace_id, maximize, focus);
            config[app_id] = app_config;
        }
    }

    public void apply_config (Gee.HashMap<string, AppConfig> new_config) {
        var builder = new VariantBuilder (new VariantType ("a(sibb)"));

        foreach (var entry in new_config.entries) {
            string app_id = entry.key;
            var app_config = entry.value;
            builder.add ("(sibb)", app_id, app_config.workspace, app_config.maximize, app_config.focus);
        }

        config = new_config;
        schema.set_value ("app-workspace-bindings", builder.end ());
    }
}