/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alain23@protonmail.com>
*/

public class Widgets.Popovers.Menu : Gtk.Popover {
    public Menu (Gtk.Widget relative) {
        Object (
            relative_to: relative,
            modal: true,
            position: Gtk.PositionType.TOP
        );
    }

    construct {
        var folder_menu = new Widgets.ModelButton (_("Change Folder"), _("Change project name"));
        
        var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
        mode_switch.margin_start = 12;
        mode_switch.primary_icon_tooltip_text = ("Light background");
        mode_switch.secondary_icon_tooltip_text = ("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;

        var label = new Gtk.Label (_("Night Mode"));
        label.margin_start = 6;

        var night_mode_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        night_mode_box.get_style_context ().add_class ("menuitem");
        night_mode_box.pack_start (label, false, false, 0);
        night_mode_box.pack_end (mode_switch, false, false, 0);

        var night_mode_eventbox = new Gtk.EventBox ();
        night_mode_eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        night_mode_eventbox.get_style_context ().add_class ("menuitem");
        night_mode_eventbox.add (night_mode_box);

        var main_grid = new Gtk.Grid ();
        main_grid.margin_top = 6;
        main_grid.margin_bottom = 6;
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.width_request = 200;

        main_grid.add (folder_menu);
        main_grid.add (night_mode_eventbox);

        add (main_grid);

        night_mode_eventbox.enter_notify_event.connect ((event) => {
            night_mode_eventbox.get_style_context ().add_class ("night-mode");
            return false;
        });

        night_mode_eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            night_mode_eventbox.get_style_context ().remove_class ("night-mode");
            return false;
        });

        night_mode_eventbox.event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                if (mode_switch.active) {
                    mode_switch.active = false;
                } else {
                    mode_switch.active = true;
                }
            }

            return false;
        });

        var gtk_settings = Gtk.Settings.get_default ();
        mode_switch.bind_property ("active", gtk_settings, "gtk_Byte_prefer_dark_theme");
        Byte.settings.bind ("prefer-dark-style", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);
    }
}
