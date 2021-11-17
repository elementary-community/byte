public class Widgets.ArtistChild : Gtk.FlowBoxChild {
    public Objects.Artist artist { get; construct; }

    public ArtistChild (Objects.Artist artist) {
        Object (
            artist: artist,
            tooltip_text: artist.name
        );
    }

    construct {
        get_style_context ().add_class ("main-child-item");

        var artist_cover = new Hdy.Avatar (32, artist.name, true) {
            hexpand = true
        };
        var artist_label = new Gtk.Label (artist.name) {
            hexpand = true,
            ellipsize = Pango.EllipsizeMode.END
        };
        artist_label.get_style_context ().add_class ("small-label");
        artist_label.get_style_context ().add_class ("font-label");

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            halign = Gtk.Align.CENTER,
            row_spacing = 6,
            margin = 6,
            width_request = 64
        };

        main_grid.add (artist_cover);
        main_grid.add (artist_label);

        add (main_grid);
    }
}