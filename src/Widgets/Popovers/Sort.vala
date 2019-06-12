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
    private Gtk.CheckButton order_reverse_button;
    public signal void mode_changed (int index);
    public signal void order_reverse (bool mode);
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

    public bool reverse {
        set {
            order_reverse_button.active = value;
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
        
        var sort_label = new Granite.HeaderLabel (_("Sort by"));
        var desc_label = new Granite.HeaderLabel (_("Desc"));

        title_radio = new Gtk.RadioButton.with_label_from_widget (null, _("Title"));
        title_radio.get_style_context ().add_class ("planner-radio");
        title_radio.get_style_context ().add_class ("h3");

        artist_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Artist"));
        artist_radio.get_style_context ().add_class ("planner-radio");
        artist_radio.get_style_context ().add_class ("h3");

        album_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Album"));
        album_radio.get_style_context ().add_class ("planner-radio");
        album_radio.get_style_context ().add_class ("h3");

        added_radio = new Gtk.RadioButton.with_label_from_widget (title_radio, _("Added date"));
        added_radio.get_style_context ().add_class ("planner-radio");
        added_radio.get_style_context ().add_class ("h3");

        order_reverse_button = new Gtk.CheckButton.with_label (_("Reversed order"));
        order_reverse_button.get_style_context ().add_class ("planner-check");
        order_reverse_button.get_style_context ().add_class ("h3");
        
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        main_box.margin = 12;
        main_box.margin_top = 6;
        main_box.pack_start (sort_label, false, false, 0);
        main_box.pack_start (title_radio, false, false, 0);
        main_box.pack_start (artist_radio, false, false, 0);
        main_box.pack_start (album_radio, false, false, 0);
        main_box.pack_start (added_radio, false, false, 0);
        main_box.pack_start (desc_label, false, false, 0);
        main_box.pack_start (order_reverse_button, false, false, 0);

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

        order_reverse_button.toggled.connect (() => {
            order_reverse (order_reverse_button.active);
        });
    }
}