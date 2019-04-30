
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

public class Blockbuster.Application : Gtk.Application {
    private MainWindow? window = null;

    public static Gtk.CssProvider css_provider;

    private static Settings settings;

    public static unowned Settings get_settings () {
        return settings;
    }

    static construct {
        css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource ("com/github/donadigo/blockbuster/application.css");

        settings = new Settings ("com.github.donadigo.blockbuster.app");
    }

    construct {
        application_id = "com.github.donadigo.blockbuster";
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.textdomain (Build.GETTEXT_PACKAGE);

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        add_accelerator ("<Control>q", "app.quit", null);
        quit_action.activate.connect (() => {
            if (window != null) {
                window.close ();
            }
        });        
    }

    public override void activate () {
        if (!settings.get_boolean ("plugin-loaded")) {
            bool plugin_running = get_plugin_running ();
            if (plugin_running) {
                settings.set_boolean ("plugin-loaded", true);
            } else {
                var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                    _("Some Components Need To Be Restarted"),
                    _("A re-login or restart is required to begin using Blockbuster. You can also start configuring settings now but they will not be applied upon a new session."),
                    "dialog-information",
                    Gtk.ButtonsType.NONE
                );

                message_dialog.add_button (_("Open Anyway"), Gtk.ResponseType.ACCEPT);
                message_dialog.add_button (_("Close"), Gtk.ResponseType.CLOSE);
                message_dialog.set_default_response (Gtk.ResponseType.CLOSE);

                Gtk.StyleContext.add_provider_for_screen (message_dialog.get_screen (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

                int response = message_dialog.run ();
                message_dialog.destroy ();
                if (response == Gtk.ResponseType.CLOSE) {
                    return;
                }
            }
        }        
        
        if (window == null) {
            window = new MainWindow ();
            add_window (window);
            window.show_all ();
        } else {
            window.present ();
        }
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run (args);
    }

    private static bool get_plugin_running () {
        if (settings.get_boolean ("plugin-loaded")) {
            return true;
        }

        string output;
        try {
            if (!Process.spawn_command_line_sync ("pidof gala", out output)) {
                return false;
            }
        } catch (SpawnError e) {
            warning (e.message);
            return false;
        }

        try {
            string contents;
            FileUtils.get_contents ("/proc/%s/maps".printf (output.strip ()), out contents);

            return contents.contains (Build.PLUGIN_PATH);
        } catch (FileError e) {
            warning (e.message);
            return false;
        }
    }
}