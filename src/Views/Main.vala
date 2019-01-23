public class Views.Main : Gtk.EventBox {
    private Granite.SeekBar timeline;
    private Gtk.Label title_label;
    private Gtk.Label artist_album_label;
    private Gtk.ListBox tracks_listbox;

    private string cache_folder;
    private string cover_folder;
    public Main () {
        Object (

        );
    }

    construct {
        cache_folder = GLib.Path.build_filename (GLib.Environment.get_user_cache_dir (), "com.github.alainm23.byte");
        cover_folder = GLib.Path.build_filename (cache_folder, "covers");

        timeline = new Granite.SeekBar (0);
        timeline.margin_top = 6;
        timeline.margin_start = 6;
        timeline.margin_end = 6;
        timeline.get_style_context ().remove_class ("seek-bar");
        timeline.get_style_context ().add_class ("byte-seekbar");

        title_label = new Gtk.Label ("<b>%s</b>".printf ("Byte"));
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.use_markup = true;

        artist_album_label = new Gtk.Label ("<b>%s</b>".printf (_("Choose a Track")));
        artist_album_label.ellipsize = Pango.EllipsizeMode.END;
        artist_album_label.use_markup = true;

        var metainfo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        metainfo_box.add (title_label);
        metainfo_box.add (artist_album_label);

        var slider_button = new Gtk.ToggleButton ();
        slider_button.get_style_context ().add_class ("slider-button");
        slider_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        slider_button.valign = Gtk.Align.CENTER;
        slider_button.can_focus = false;

        var slider_icon = new Gtk.Image ();
        slider_icon.gicon = new ThemedIcon ("slider-symbolic");
        slider_icon.pixel_size = 16;

        slider_button.add (slider_icon);

        var info_button = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.MENU);
        info_button.can_focus = false;
        info_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.margin_top = 6;
        header_box.margin_start = 9;
        header_box.margin_end = 9;
        header_box.margin_bottom = 9;
        header_box.spacing = 6;
        header_box.add (slider_button);
        header_box.pack_end (info_button, false, false, 0);
        header_box.pack_end (metainfo_box, true, true, 0);

        var image_cover = new Gtk.Image ();
        image_cover.gicon = new ThemedIcon ("byte-drag-music");
        image_cover.pixel_size = 128;
        
        var image_grid = new Gtk.Grid ();
        image_grid.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        image_grid.valign = Gtk.Align.CENTER;
        image_grid.margin_bottom = 12;
        image_grid.halign = Gtk.Align.CENTER;
        image_grid.add (image_cover);

        var image_cover_revealer = new Gtk.Revealer ();
        image_cover_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        image_cover_revealer.add (image_grid);

        tracks_listbox = new Gtk.ListBox  ();
        tracks_listbox.activate_on_single_click = true;
        tracks_listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        tracks_listbox.expand = true;

        var tracks_scrolled = new Gtk.ScrolledWindow (null, null);
        tracks_scrolled.add (tracks_listbox);

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (timeline);
        main_grid.add (header_box);
        main_grid.add (image_cover_revealer);
        main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_grid.add (tracks_scrolled);

        add (main_grid);
        update_project_list ();

        tracks_listbox.set_filter_func ((row) => {
            if (row.get_index () % 2 == 0) {
                row.get_style_context ().add_class ("background");
            } else {
                row.get_style_context ().add_class ("view");
            }
            
            return true;
        });

        info_button.clicked.connect (() => {
            
        });

        slider_button.toggled.connect (() => {
            if (slider_button.active) {
                slider_button.get_style_context ().add_class ("active");
                image_cover_revealer.reveal_child = true;
            } else {
                slider_button.get_style_context ().remove_class ("active");
                image_cover_revealer.reveal_child = false;
            }
        });

        Application.player.current_progress_changed.connect ((progress) => {
            timeline.playback_progress = progress;
            if (timeline.playback_duration == 0) {
                timeline.playback_duration = Application.player.duration / Gst.SECOND;
            }
        });

        Application.player.current_duration_changed.connect ((duration) => {
            timeline.playback_duration = duration / Gst.SECOND;
        });

        timeline.scale.change_value.connect ((scroll, new_value) => {
            Application.player.seek_to_progress (new_value);
            return true;
        });

        tracks_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;

            Application.player.set_track (item.track);

            title_label.label = "<b>%s</b>".printf (item.track.title);
            artist_album_label.label = "%s - %s".printf (item.track.artist, item.track.album);

            if (item.is_pixbuf == true) {
                image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (item.path_cover, 128, 128);
            } else {
                image_cover.gicon = new ThemedIcon ("byte-drag-music");
            }
        });

        Application.player.current_track_changed.connect ((track) => {
            tracks_listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;

                if (track.id == item.track.id) {
                    tracks_listbox.select_row (row);
                }
                
                return true;
            });
        });

        Application.database.adden_new_track.connect ((track) => {
            try {
                Idle.add (() => {
                    var item = new Widgets.TrackRow (track);
                    
                    tracks_listbox.add (item);

                    tracks_listbox.show_all ();
                    return false;
                });
            } catch (Error err) {
                warning ("%s\n", err.message);
            }
        });
    }

    public void update_project_list () {
        var all_tracks = new Gee.ArrayList<Objects.Track?> ();
        all_tracks = Application.database.get_all_tracks ();

        foreach (var track in all_tracks) {
            var row = new Widgets.TrackRow (track);

            tracks_listbox.add (row);

            Application.utils.add_track_playlist (track);
        }

        tracks_listbox.show_all ();
    }
}
