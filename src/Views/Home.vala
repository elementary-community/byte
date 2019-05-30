public class Views.Home : Gtk.EventBox {
    public signal void go_albums_view ();
    
    public Home () {}

    construct {
        // Spinner loading
        var loading_spinner = new Gtk.Spinner ();
        loading_spinner.active = true;
        loading_spinner.start ();

        var loading_label = new Gtk.Label (_("Sync library…"));

        var loading_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        loading_box.halign = Gtk.Align.CENTER;
        loading_box.hexpand = true;
        loading_box.margin = 6;
        loading_box.add (loading_spinner);
        loading_box.add (loading_label);

        var loading_revealer = new Gtk.Revealer ();
        loading_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        loading_revealer.add (loading_box);
        loading_revealer.reveal_child = false;

        var library_label = new Gtk.Label ("<b>%s</b>".printf (_("Library")));
        library_label.get_style_context ().add_class ("header-label");
        library_label.margin_start = 9;
        library_label.margin_top = 6;
        library_label.halign =Gtk.Align.START;
        library_label.use_markup = true;
        
        var playlist_label = new Gtk.Label ("<b>%s</b>".printf (_("Playlists")));
        playlist_label.get_style_context ().add_class ("sub-header-label");
        playlist_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        playlist_label.halign =Gtk.Align.START;
        playlist_label.use_markup = true;

        var playlists_button = new Gtk.Button.with_label (_("View all"));
        playlists_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        playlists_button.get_style_context ().add_class ("button-color");
        playlists_button.can_focus = false;
        playlists_button.valign = Gtk.Align.CENTER;

        var playlists_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        playlists_box.margin_start = 9;
        playlists_box.pack_start (playlist_label, false, false, 0);
        playlists_box.pack_end (playlists_button, false, false, 0);

        var artists_label = new Gtk.Label ("<b>%s</b>".printf (_("Artists")));
        artists_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        artists_label.get_style_context ().add_class ("sub-header-label");
        artists_label.halign =Gtk.Align.START;
        artists_label.use_markup = true;

        var artists_button = new Gtk.Button.with_label (_("View all"));
        artists_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        artists_button.get_style_context ().add_class ("button-color");
        artists_button.can_focus = false;
        artists_button.valign = Gtk.Align.CENTER;

        var artists_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        artists_box.margin_start = 9;
        artists_box.pack_start (artists_label, false, false, 0);
        artists_box.pack_end (artists_button, false, false, 0);

        var albums_label = new Gtk.Label ("<b>%s</b>".printf (_("Albums")));
        albums_label.get_style_context ().add_class ("sub-header-label");
        albums_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        albums_label.halign =Gtk.Align.START;
        albums_label.use_markup = true;

        var albums_button = new Gtk.Button.with_label (_("View all"));
        albums_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        albums_button.get_style_context ().add_class ("button-color");
        albums_button.can_focus = false;
        albums_button.valign = Gtk.Align.CENTER;

        var albums_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        albums_box.margin_start = 9;
        albums_box.pack_start (albums_label, false, false, 0);
        albums_box.pack_end (albums_button, false, false, 0);

        var tracks_label = new Gtk.Label ("<b>%s</b>".printf (_("Tracks")));
        tracks_label.get_style_context ().add_class ("sub-header-label");
        tracks_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        tracks_label.halign =Gtk.Align.START;
        tracks_label.use_markup = true;

        var tracks_button = new Gtk.Button.with_label (_("View all"));
        tracks_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        tracks_button.get_style_context ().add_class ("button-color");
        tracks_button.can_focus = false;
        tracks_button.valign = Gtk.Align.CENTER;

        var tracks_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        tracks_box.margin_start = 9;
        tracks_box.pack_start (tracks_label, false, false, 0);
        tracks_box.pack_end (tracks_button, false, false, 0);

        var radio_label = new Gtk.Label ("<b>%s</b>".printf (_("Radios")));
        radio_label.get_style_context ().add_class ("header-label");
        radio_label.margin_start = 9;
        radio_label.margin_top = 6;
        radio_label.halign =Gtk.Align.START;
        radio_label.use_markup = true;

        var podcast_label = new Gtk.Label ("<b>%s</b>".printf (_("Podcast")));
        podcast_label.get_style_context ().add_class ("header-label");
        podcast_label.margin_start = 9;
        podcast_label.margin_top = 6;
        podcast_label.halign =Gtk.Align.START;
        podcast_label.use_markup = true;

        var library_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_box.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        library_box.get_style_context ().add_class ("w-round");
        library_box.expand = true;
        library_box.pack_start (loading_revealer, false, true, 0);
        library_box.pack_start (library_label, false, false, 0);
        library_box.pack_start (playlists_box, false, false, 0);
        library_box.pack_start (artists_box, false, false, 0);
        library_box.pack_start (albums_box, false, false, 0);
        library_box.pack_start (tracks_box, false, false, 0);
        library_box.pack_start (radio_label, false, false, 0);
        library_box.pack_start (podcast_label, false, false, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (library_box, true, true, 0);

        add (main_box);

        Byte.scan_service.sync_started.connect (() => {
            loading_revealer.reveal_child = true;
        });

        Byte.scan_service.sync_finished.connect (() => {
            loading_revealer.reveal_child = false;
        });

        albums_button.clicked.connect (() => {
            go_albums_view ();
        });
        /*
        

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
        header_box.margin_start = 12;
        header_box.margin_end = 9;
        header_box.margin_bottom = 9;
        header_box.spacing = 6;
        header_box.add (slider_button);
        header_box.pack_end (info_button, false, false, 0);
        header_box.pack_end (metainfo_box, true, true, 0);

        var image_cover = new Gtk.Image ();
        image_cover.gicon = new ThemedIcon ("byte-drag-music");
        image_cover.pixel_size = 96;
        image_cover.margin = 3;
        
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
        //tracks_listbox.activate_on_single_click = true;
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
            var editor_dialog = new Dialogs.TrackEditor (Byte.player.current_track);
            editor_dialog.destroy.connect (Gtk.main_quit);
            editor_dialog.show_all ();
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

        Byte.player.current_progress_changed.connect ((progress) => {
            timeline.playback_progress = progress;
            if (timeline.playback_duration == 0) {
                timeline.playback_duration = Byte.player.duration / Gst.SECOND;
            }
        });

        Byte.player.current_duration_changed.connect ((duration) => {
            timeline.playback_duration = duration / Gst.SECOND;
        });

        Byte.player.current_track_changed.connect ((track) => {
            title_label.label = "<b>%s</b>".printf (track.title);
            artist_album_label.label = "%s - %s".printf (track.artist, track.album);
            image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (track.cover, 96, 96);
        });

        timeline.scale.change_value.connect ((scroll, new_value) => {
            Byte.player.seek_to_progress (new_value);
            return true;
        });

        tracks_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;
            Byte.player.set_track (item.track);
        });

        Byte.player.current_track_changed.connect ((track) => {
            tracks_listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;

                if (track.id == item.track.id) {
                    tracks_listbox.select_row (row);
                }
                
                return true;
            });
        });

        Byte.database.adden_new_track.connect ((track) => {
            try {
                Idle.add (() => {
                    var item = new Widgets.TrackRow (track);
                    
                    tracks_listbox.add (item); 
                    Byte.utils.add_track_playlist (track);
                    
                    tracks_listbox.show_all ();
                    return false;
                });
            } catch (Error err) {
                warning ("%s\n", err.message);
            }
        });
        */
    }

    public void update_project_list () {
        /*
        var all_tracks = new Gee.ArrayList<Objects.Track?> ();
        all_tracks = Byte.database.get_all_tracks ();

        foreach (var track in all_tracks) {
            var row = new Widgets.TrackRow (track);
            tracks_listbox.add (row);
        }

        tracks_listbox.show_all ();
        */
    }
}
