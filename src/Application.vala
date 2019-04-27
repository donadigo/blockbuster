
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
    construct {
        application_id = "com.github.donadigo.blockbuster";
    }

    public override void activate () {
        var window = new MainWindow ();
        add_window (window);
        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run (args);
    }
}