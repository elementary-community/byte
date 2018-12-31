public class Views.Main : Gtk.EventBox {
    private Granite.SeekBar seekbar;
    private Gtk.Label title_label;
    private Gtk.Label artist_album_label;
    private Gtk.ListBox listbox;

    public Main () {
        Object (

        );
    }

    construct {
        seekbar = new Granite.SeekBar (0);
        seekbar.margin_top = 12;
        seekbar.margin_start = 12;
        seekbar.margin_end = 12;
        seekbar.get_style_context ().remove_class ("seek-bar");
        seekbar.get_style_context ().add_class ("byte-seekbar");

        title_label = new Gtk.Label (null);
        title_label.use_markup = true;

        artist_album_label = new Gtk.Label (null);

        var metainfo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        metainfo_box.add (title_label);
        metainfo_box.add (artist_album_label);

        var slider_button = new Gtk.Button.from_icon_name ("view-column-symbolic", Gtk.IconSize.MENU);
        slider_button.can_focus = false;
        slider_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var info_button = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.MENU);
        info_button.can_focus = false;
        info_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.margin_start = 12;
        header_box.margin_end = 12;
        header_box.add (slider_button);
        header_box.pack_end (info_button, false, false, 0);
        header_box.pack_end (metainfo_box, true, true, 0);

        var image_cover = new Gtk.Image.from_file ("/home/alain/.cache/com.github.artemanufrij.playmymusic/covers/album_4.jpg");
        image_cover.valign = Gtk.Align.CENTER;
        image_cover.halign = Gtk.Align.CENTER;
        image_cover.pixel_size = 128;

        listbox = new Gtk.ListBox  ();
        listbox.get_style_context ().add_class (Gtk.STYLE_CLASS_BACKGROUND);
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        listbox.expand = true;

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        var main_grid = new Gtk.Grid ();
        main_grid.row_spacing = 6;
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (seekbar);
        main_grid.add (header_box);
        //main_grid.add (image_cover);
        main_grid.add (scrolled_window);

        add (main_grid);
        update_project_list ();

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

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;

            Application.stream_player.ready_file (item.track.path);
            Application.stream_player.play_file ();

            title_label.label = "<b>%s</b>".printf (item.track.title);
            artist_album_label.label = "%s - %s".printf (item.track.artist, item.track.album);
        });

        Application.database.adden_new_track.connect ((track) => {
            try {
                Idle.add (() => {
                    var item = new Widgets.TrackRow (track);
                    listbox.add (item);

                    listbox.show_all ();
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
            listbox.add (row);
        }

        listbox.show_all ();
    }
}
