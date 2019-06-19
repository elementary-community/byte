public class Widgets.PlaylistRow : Gtk.ListBoxRow {
    public Objects.Playlist playlist { get; construct; }

    private Gtk.Label title_label;
    private Widgets.Cover image_cover;
    private string cover_path;
    public PlaylistRow (Objects.Playlist playlist) {
        Object (
            playlist: playlist
        );
    }

    construct {
        tooltip_text = playlist.title;
        get_style_context ().add_class ("album-child");

        title_label = new Gtk.Label (playlist.title);
        title_label.get_style_context ().add_class ("font-bold");
        title_label.get_style_context ().add_class ("h3");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.CENTER;

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("playlist-%i.jpg").printf (playlist.id));
        image_cover = new Widgets.Cover.from_file (cover_path, 48, "playlist");

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 3;
        main_grid.add (image_cover);
        main_grid.add (title_label);

        add (main_grid);
    }
}