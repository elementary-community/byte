public class Widgets.TrackChild : Gtk.FlowBoxChild {
    public Objects.Track track { get; construct; }
    
    public TrackChild (Objects.Track track) {
        Object (
            track: track,
            tooltip_markup: "<b>%s</b>\n%s".printf (track.title, track.album.artist.name)
        );
    }

    construct {
        get_style_context ().add_class ("main-child-item");

        var album_image = new Widgets.AlbumImage (32);
        album_image.set_pixbuf (track.get_pixbuf (32));

        var title_label = new Gtk.Label (track.title) {
            ellipsize = Pango.EllipsizeMode.END,
            halign = Gtk.Align.START,
            valign = Gtk.Align.END,
            xalign = 0
        };
        title_label.get_style_context ().add_class ("font-bold");
        title_label.get_style_context ().add_class ("small-label");

        var album_label = new Gtk.Label (track.album.title) {
            margin_top = 3,
            ellipsize = Pango.EllipsizeMode.END,
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            xalign = 0
        };
        album_label.get_style_context ().add_class ("dim-label");
        album_label.get_style_context ().add_class ("small-label");

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 6,
            width_request = 112,
            column_spacing = 6
        };

        main_grid.attach (album_image, 0, 0, 1, 2);
        main_grid.attach (title_label, 1, 0, 1, 1);
        main_grid.attach (album_label, 1, 1, 1, 1);

        add (main_grid);
    }
}