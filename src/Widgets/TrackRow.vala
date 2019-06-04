public class Widgets.TrackRow : Gtk.ListBoxRow {
    public Objects.Track track { get; construct; }

    private Gtk.Label track_title_label;
    private Gtk.Label artist_album_label;
    private Gtk.Label duration_label;

    private Widgets.Cover image_cover;

    private string cover_path;

    public TrackRow (Objects.Track track) {
        Object (
            track: track
        );
    }

    construct {
        get_style_context ().add_class ("track-row");

        track_title_label = new Gtk.Label (track.title);
        track_title_label.get_style_context ().add_class ("font-bold");
        track_title_label.ellipsize = Pango.EllipsizeMode.END;
        track_title_label.max_width_chars = 45;
        track_title_label.halign = Gtk.Align.START;
        track_title_label.valign = Gtk.Align.END;

        artist_album_label = new Gtk.Label ("%s - %s".printf (track.artist_name, track.album_title));
        artist_album_label.halign = Gtk.Align.START;
        artist_album_label.valign = Gtk.Align.START;
        artist_album_label.max_width_chars = 45;
        artist_album_label.ellipsize = Pango.EllipsizeMode.END;

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (track.album_id));
        image_cover = new Widgets.Cover.from_file (cover_path, 32, "track");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        duration_label = new Gtk.Label (Byte.utils.get_formated_duration (track.duration));
        duration_label.halign = Gtk.Align.END;
        duration_label.hexpand = true;

        var main_grid = new Gtk.Grid ();
        main_grid.margin_start = 3;
        main_grid.margin_end = 9;
        main_grid.column_spacing = 6;
        main_grid.attach (image_cover, 0, 0, 1, 2);
        main_grid.attach (track_title_label, 1, 0, 1, 1);
        main_grid.attach (artist_album_label, 1, 1, 1, 1);
        main_grid.attach (duration_label, 2, 0, 2, 2);

        add (main_grid);
    }
}
