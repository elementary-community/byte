/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/byte)
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

public class Widgets.Popovers.TrackOptions : Gtk.Popover {
    public Objects.Track track { get; construct; }

    public signal void on_selected_menu (string name);
    public TrackOptions (Gtk.Widget relative, Objects.Track track) {
        Object (
            relative_to: relative,
            modal: true,
            position: Gtk.PositionType.LEFT,
            track: track
        );
    }

    construct {
        var primary_label = new Gtk.Label (track.title);
        primary_label.get_style_context ().add_class ("font-bold");
        primary_label.ellipsize = Pango.EllipsizeMode.END;
        primary_label.max_width_chars = 25;
        primary_label.halign = Gtk.Align.START;
        primary_label.valign = Gtk.Align.END;

        var secondary_label = new Gtk.Label ("%s - %s".printf (track.artist_name, track.album_title));
        secondary_label.halign = Gtk.Align.START;
        secondary_label.valign = Gtk.Align.START;
        secondary_label.max_width_chars = 25;
        secondary_label.ellipsize = Pango.EllipsizeMode.END;
        
        var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (track.album_id));
        var image_cover = new Widgets.Cover.from_file (cover_path, 32, "track");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        var track_grid = new Gtk.Grid ();
        track_grid.column_spacing = 6;
        track_grid.margin_end = 6;
        track_grid.attach (image_cover, 0, 0, 1, 2);
        track_grid.attach (primary_label, 1, 0, 1, 1);
        track_grid.attach (secondary_label, 1, 1, 1, 1);

        var play_menu = new ModelButton (_("Play / Pause"), "media-playback-start-symbolic", _("Finalize project"));
        var add_playlist_menu = new ModelButton (_("Add to Playlist"), "list-add-symbolic", _("Change project name"));
        var play_next_menu = new ModelButton (_("Play Next"), "document-export-symbolic", _("Export project"));
        var play_last_menu = new ModelButton (_("Play Last"), "emblem-shared-symbolic", _("Share project"));
        
        var separator_1 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator_1.margin_top = 3;
        separator_1.margin_bottom = 3;
        separator_1.expand = true;

        var separator_2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator_2.margin_top = 3;
        separator_2.margin_bottom = 3;
        separator_2.expand = true;

        var separator_3 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator_3.margin_top = 3;
        separator_3.margin_bottom = 3;
        separator_3.expand = true;
        
        var main_grid = new Gtk.Grid ();
        main_grid.margin_bottom = 6;
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.width_request = 200;

        main_grid.add (track_grid);
        main_grid.add (play_menu);
        main_grid.add (add_playlist_menu);
        main_grid.add (play_next_menu);
        main_grid.add (play_last_menu);
        //main_grid.add (separator_2);
        //main_grid.add (export_menu);
        //main_grid.add (share_menu);
        //main_grid.add (separator_3);
        //main_grid.add (archived_menu);
        //main_grid.add (remove_menu);
   
        add (main_grid);
    }
}

public class ModelButton : Gtk.Button {
    private Gtk.Label _label;
    private Gtk.Image _image;

    public string icon {
        set {
            _image.gicon = new ThemedIcon (value);
        }
    }
    public string tooltip {
        set {
            tooltip_text = value;
        }
    }
    public string text { 
        set {
            _label.label = value;
        }
    }
    

    public ModelButton (string _text, string _icon, string _tooltip) {
        Object (
            icon: _icon,
            text: _text,
            tooltip: _tooltip,
            expand: true
        );
    }

    construct {
        get_style_context ().remove_class ("button");
        get_style_context ().add_class ("menuitem");

        _label = new Gtk.Label (null);

        _image = new Gtk.Image ();
        _image.pixel_size = 16;
        
        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.add (_image);
        grid.add (_label);

        add (grid);
    }
}
