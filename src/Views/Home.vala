public class Views.Home : Gtk.EventBox {
    public signal void go_albums_view ();
    public signal void go_tracks_view ();
    public signal void go_artists_view ();

    private Gtk.FlowBox albums_flowbox;
    public Home () {}

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        get_style_context ().add_class ("w-round");

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
        library_label.get_style_context ().add_class ("font-bold");
        library_label.margin_start = 9;
        library_label.margin_top = 6;
        library_label.halign =Gtk.Align.START;
        library_label.use_markup = true;
        
        var recently_added_label = new Gtk.Label ("<b>%s</b>".printf (_("Recently added")));
        recently_added_label.get_style_context ().add_class ("font-bold");
        recently_added_label.margin_start = 9;
        recently_added_label.halign =Gtk.Align.START;
        recently_added_label.use_markup = true;

        var playlists_button = new Widgets.HomeButton (_("Playlists"), "airplane-mode-symbolic");
        var albums_button = new Widgets.HomeButton (_("Albums"), "media-optical-symbolic");
        var songs_button = new Widgets.HomeButton (_("Songs"), "folder-music-symbolic");
        var artists_button = new Widgets.HomeButton ("Artists", "airplane-mode-symbolic");
        var radios_button = new Widgets.HomeButton ("Radios", "airplane-mode-symbolic");
        var favorites_button = new Widgets.HomeButton ("Favorites", "emblem-favorite-symbolic");

        var items_grid = new Gtk.Grid ();
        items_grid.row_spacing = 12;
        items_grid.column_spacing = 12;
        items_grid.margin = 6;
        items_grid.margin_top = 12;
        items_grid.margin_bottom = 12;
        items_grid.margin_end = 12;
        items_grid.column_homogeneous = true;
        items_grid.row_homogeneous = true;
        items_grid.attach (songs_button,     0, 0, 1, 1);
        items_grid.attach (albums_button,    1, 0, 1, 1);
        items_grid.attach (playlists_button, 0, 1, 1, 1);
        items_grid.attach (artists_button, 1, 1, 1, 1);
        items_grid.attach (favorites_button,    0, 2, 1, 1);
        items_grid.attach (radios_button,   1, 2, 1, 1);

        var library_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_box.vexpand = true;
        library_box.hexpand = false;
        library_box.pack_start (loading_revealer, false, false, 0);
        library_box.pack_start (library_label, false, false, 0);
        library_box.pack_start (items_grid, false, false, 0);
        library_box.pack_start (recently_added_label, false, false, 0);

        // Test cover url
        //string url = "https://lh5.googleusercontent.com/-M9SHjyVhB-c/AAAAAAAAAAI/AAAAAAAABjY/2clsC6leKaw/photo.jpg";
        //var cover = new Widgets.Cover.from_url_async (url, 64, true, "artist");

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.expand = true;
        scrolled_window.add (library_box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (scrolled_window, true, true, 0);

        add (main_box);

        albums_button.clicked.connect (() => {
            go_albums_view ();
        });

        songs_button.clicked.connect (() => {
            go_tracks_view ();
        });

        artists_button.clicked.connect (() => {
            go_artists_view ();
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
