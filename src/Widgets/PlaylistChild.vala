public class Widgets.PlaylistChild : Gtk.FlowBoxChild {
    public Objects.Track track { get; construct; }

    public PlaylistChild (Objects.Track track) {
        Object (
            track: track,
            tooltip_markup: "<b>%s</b>\n%s".printf (track.title, track.album.title)
        );
    }

    construct {
        get_style_context ().add_class ("main-child-item");

        var track_cover = new Hdy.Avatar (96, track.album.title, true) {
            hexpand = true,
            halign = Gtk.Align.START
        };
        track_cover.get_style_context ().add_class ("border-radius");

        var title_label = new Gtk.Label (track.title) {
            margin_top = 6,
            ellipsize = Pango.EllipsizeMode.END,
            halign = Gtk.Align.START,
            xalign = 0
        };
        title_label.get_style_context ().add_class ("font-bold");
        title_label.get_style_context ().add_class ("small-label");

        var album_label = new Gtk.Label (track.album.title) {
            margin_top = 3,
            ellipsize = Pango.EllipsizeMode.END,
            halign = Gtk.Align.START,
            xalign = 0
        };
        album_label.get_style_context ().add_class ("dim-label");
        album_label.get_style_context ().add_class ("small-label");

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL,
            margin = 6,
            width_request = 96
        };

        main_grid.add (track_cover);
        main_grid.add (title_label);
        main_grid.add (album_label);

        add (main_grid);
    }
}