public class Widgets.TrackRow : Gtk.ListBoxRow {
    public Objects.Track track { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_album_label;
    private Gtk.Label duration_label;

    public TrackRow (Objects.Track _track) {
        Object (
            track: _track
        );
    }

    construct {
        get_style_context ().add_class ("track-row");

        var image = new Granite.Widgets.Avatar.with_default_icon (32);

        title_label = new Gtk.Label ("<b>%s</b>".printf (track.title));
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.use_markup = true;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.END;

        artist_album_label = new Gtk.Label ("%s - %s".printf (track.artist, track.album));
        artist_album_label.halign = Gtk.Align.START;
        artist_album_label.valign = Gtk.Align.START;
        artist_album_label.ellipsize = Pango.EllipsizeMode.END;

        //duration_label = new Gtk.Label (track.duration.to_string ());

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.attach (image, 0, 0, 1, 2);
        main_grid.attach (title_label, 1, 0, 1, 1);
        main_grid.attach (artist_album_label, 1, 1, 1, 1);
        //main_grid.attach (duration_label, 2, 0, 2, 2);

        add (main_grid);
    }
}
