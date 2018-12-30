public class Views.Main : Gtk.EventBox {
    private Granite.SeekBar seekbar;


    public Main () {
        Object (

        );
    }

    construct {
        seekbar = new Granite.SeekBar (0);
        seekbar.get_style_context ().remove_class ("seek-bar");
        seekbar.get_style_context ().add_class ("byte-seekbar");

        var title_label = new Gtk.Label (null);
        title_label.use_markup = true;

        var artist_album_label = new Gtk.Label (null);

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
        header_box.add (slider_button);
        header_box.pack_end (info_button, false, false, 0);
        header_box.pack_end (metainfo_box, true, true, 0);

        var main_grid = new Gtk.Grid ();
        main_grid.row_spacing = 6;
        main_grid.margin = 12;
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (seekbar);
        main_grid.add (header_box);

        add (main_grid);

        Application.signals.play_track.connect (() => {
            Application.stream_player.play_file ();

            title_label.label = "<b>%s</b>".printf (Application.stream_player.metadata.title);
            artist_album_label.label = "%s - %s".printf (Application.stream_player.metadata.artist, Application.stream_player.metadata.album);
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
    }
}
