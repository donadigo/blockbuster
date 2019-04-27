
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
    }

    public Gee.HashMap<string, AppConfig> get_config (int[] exclude = {}) {
        var map = new Gee.HashMap<string, AppConfig> ();

        var val = schema.get_value ("app-workspace-bindings");
        for (int i = 0; i < val.n_children (); i++) {
			var child = val.get_child_value (i);
			if (child.n_children () < 4) {
				continue;
            }
            
            int workspace_id = child.get_child_value (1).get_int32 ();
            if (workspace_id in exclude) {
                continue;
            }

			string app_id = child.get_child_value (0).get_string ();
			bool maximize = child.get_child_value (2).get_boolean ();
            bool focus = child.get_child_value (3).get_boolean ();
            
            var config = new AppConfig (workspace_id, maximize, focus);
            map[app_id] = config;
        }

        return map;
    }

    public void set_config (Gee.HashMap<string, AppConfig> config) {
        var builder = new VariantBuilder (new VariantType ("a(sibb)"));

        foreach (var entry in config.entries) {
            string app_id = entry.key;
            var app_config = entry.value;
            builder.add ("(sibb)", app_id, app_config.workspace, app_config.maximize, app_config.focus);
        }

        schema.set_value ("app-workspace-bindings", builder.end ());        
    }

    public void set_config_variant (Variant v) {
        schema.set_value ("app-workspace-bindings", v);
    }
}