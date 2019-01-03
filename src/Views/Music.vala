public class Views.Music : Gtk.EventBox {
    private Granite.SeekBar seekbar;
    private Gtk.Label title_label;
    private Gtk.Label artist_album_label;
    private Gtk.ListBox tracks_listbox;

    private Widgets.TrackEditor track_editor;

    private string cache_folder;
    private string cover_folder;
    private double vadjustment_value_old = 0;
    private bool search_entry_activate = false;

    private Objects.Track track_playing;
    public Music () {
        Object (

        );
    }

    construct {
        cache_folder = GLib.Path.build_filename (GLib.Environment.get_user_cache_dir (), "com.github.alainm23.byte");
        cover_folder = GLib.Path.build_filename (cache_folder, "covers");

        seekbar = new Granite.SeekBar (0);
        seekbar.margin_top = 6;
        seekbar.margin_start = 6;
        seekbar.margin_end = 6;
        seekbar.get_style_context ().remove_class ("seek-bar");
        seekbar.get_style_context ().add_class ("byte-seekbar");

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
        slider_icon.gicon = new ThemedIcon ("view-column-symbolic");
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
        header_box.add (slider_button);
        header_box.pack_end (info_button, false, false, 0);
        header_box.pack_end (metainfo_box, true, true, 0);

        var image_cover = new Gtk.Image ();
        image_cover.valign = Gtk.Align.CENTER;
        image_cover.halign = Gtk.Align.CENTER;
        image_cover.gicon = new ThemedIcon ("byte-drag-music");
        image_cover.pixel_size = 128;
        image_cover.margin_bottom = 12;

        var image_cover_revealer = new Gtk.Revealer ();
        image_cover_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        image_cover_revealer.add (image_cover);

        var search_entry = new Gtk.SearchEntry ();
        search_entry.placeholder_text = _("Search a track, artist or album");
        search_entry.margin = 3;

        var search_revealer = new Gtk.Revealer ();
        search_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        search_revealer.add (search_entry);
        search_revealer.reveal_child = false;

        tracks_listbox = new Gtk.ListBox  ();
        tracks_listbox.activate_on_single_click = true;
        tracks_listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        tracks_listbox.expand = true;

        var tracks_scrolled = new Gtk.ScrolledWindow (null, null);
        tracks_scrolled.add (tracks_listbox);

        track_editor = new Widgets.TrackEditor ();

        var stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        stack.add_named (tracks_scrolled, "tracks_listbox");
        stack.add_named (track_editor, "track_editor");

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (seekbar);
        main_grid.add (header_box);
        main_grid.add (image_cover_revealer);
        main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_grid.add (search_revealer);
        main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_grid.add (stack);

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

        tracks_scrolled.vadjustment.value_changed.connect (() => {
            if (search_entry_activate == false) {
                if (tracks_scrolled.vadjustment.value < vadjustment_value_old) {
                    search_revealer.reveal_child = false;
                } else {
                    search_revealer.reveal_child = true;
                    search_entry.grab_focus ();
                }

                vadjustment_value_old = tracks_scrolled.vadjustment.value;
            }
        });

        search_entry.search_changed.connect (() => {
            search_entry_activate = true;

            tracks_listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;

                return search_entry.text in item.track.title.down () ||
                       search_entry.text in item.track.artist.down () ||
                       search_entry.text in item.track.album.down ();
            });
        });

        Timeout.add (200, () => {
            stack.visible_child_name = "tracks_listbox";
            return false;
        });

        track_editor.on_signal_back_button.connect (() => {
            stack.visible_child_name = "tracks_listbox";
        });

        info_button.clicked.connect (() => {
            if (stack.visible_child_name == "tracks_listbox") {
                track_editor.track = track_playing;
                
                stack.visible_child_name = "track_editor";
            } else {
                stack.visible_child_name = "tracks_listbox";
            }
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

        Application.signals.play_track.connect (() => {
            Application.stream_player.play_file ();
        });

        Application.signals.pause_track.connect (() => {
            Application.stream_player.pause_file ();
        });

        Application.signals.ready_file.connect (() => {
             seekbar.playback_duration = Application.stream_player.get_duration ();
        });

        seekbar.scale.change_value.connect((slider, scroll, new_value) => {
            Application.stream_player.set_position ((float) new_value);
            return true;
        });

        GLib.Timeout.add_seconds (1, () => {
            StreamTimeInfo pos_info = Application.utils.get_position_str ();
            StreamTimeInfo dur_info = Application.utils.get_duration_str ();

            // Update Seek bar info. It will automaticlly update the scale and the labels
            seekbar.playback_duration = (double)(dur_info.nanoseconds / 1000000000.0);
            seekbar.playback_progress = (double)(pos_info.nanoseconds / 1000000000.0) / seekbar.playback_duration;

            return true;
        });

        tracks_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;
            track_playing = item.track;

            Application.stream_player.ready_file (item.track.path);
            Application.stream_player.play_file ();

            title_label.label = "<b>%s</b>".printf (item.track.title);
            artist_album_label.label = "%s - %s".printf (item.track.artist, item.track.album);

            if (item.is_pixbuf == true) {
                image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (item.path_cover, 128, 128);
            } else {
                image_cover.gicon = new ThemedIcon ("byte-drag-music");
            }

            search_entry_activate = false;
            search_revealer.reveal_child = false;
            search_entry.text = "";

            tracks_listbox.set_filter_func ((row) => {
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
        }

        tracks_listbox.show_all ();
    }
}
