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

public class Widgets.Popovers.Sort : Gtk.Popover {
    private Gtk.RadioButton title_radio;
    private Gtk.RadioButton artist_radio;
    private Gtk.RadioButton album_radio;
    private Gtk.RadioButton added_radio;

    public signal void mode_changed (int index);
    public int selected {
        set {
            if (value == 0) {
                title_radio.active = true;
            } else if (value == 1) {
                artist_radio.active = true;
            } else if (value == 2) {
                album_radio.active = true;
            } else if (value == 3) {
                added_radio.active = true;
            }
        }
    }

    public Sort (Gtk.Widget relative) {
        Object (
            relative_to: relative,
            modal: true,
            position: Gtk.PositionType.BOTTOM
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        
        var title_label = new Granite.HeaderLabel (_("Sort by"));

        title_radio = new Gtk.RadioButton.with_label_from_widget (null, _("Title"));
        title_radio.get_style_context ().add_class ("sort-radio");
        title_radio.get_style_context ().add_class ("h3");

        artist_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Artist"));
        artist_radio.get_style_context ().add_class ("sort-radio");
        artist_radio.get_style_context ().add_class ("h3");

        album_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Album"));
        album_radio.get_style_context ().add_class ("sort-radio");
        album_radio.get_style_context ().add_class ("h3");

        added_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Added date"));
        added_radio.get_style_context ().add_class ("sort-radio");
        added_radio.get_style_context ().add_class ("h3");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        main_box.margin = 12;
        main_box.margin_top = 6;
        main_box.pack_start (title_label, false, false, 0);
        main_box.pack_start (title_radio, false, false, 0);
        main_box.pack_start (artist_radio, false, false, 0);
        main_box.pack_start (album_radio, false, false, 0);
        main_box.pack_start (added_radio, false, false, 0);

        add (main_box);

        title_radio.toggled.connect (() => {
            mode_changed (0);
        });

        artist_radio.toggled.connect (() => {
            mode_changed (1);
        });

        album_radio.toggled.connect (() => {
            mode_changed (2);
        });

        added_radio.toggled.connect (() => {
            mode_changed (3);
        });
    }
}