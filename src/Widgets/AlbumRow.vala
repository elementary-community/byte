public class Widgets.AlbumRow : Gtk.ListBoxRow {
    public Objects.Album album { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_label;

    private Widgets.Cover image_cover;

    private string cover_path;
    public AlbumRow (Objects.Album album) {
        Object (
            album: album
        );
    }

    construct {
        tooltip_text = album.title;
        get_style_context ().add_class ("album-child");

        title_label = new Gtk.Label (album.title);
        title_label.get_style_context ().add_class ("font-bold");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;
        title_label.max_width_chars = 45;
        title_label.valign = Gtk.Align.END;

        artist_label = new Gtk.Label (album.artist_name);
        artist_label.halign = Gtk.Align.START;
        artist_label.valign = Gtk.Align.START;
        artist_label.ellipsize = Pango.EllipsizeMode.END;

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Widgets.Cover.from_file (cover_path, 48, "album");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 3;
        main_grid.attach (image_cover, 0, 0, 1, 2);
        main_grid.attach (title_label, 1, 0, 1, 1);
        main_grid.attach (artist_label, 1, 1, 1, 1);

        add (main_grid);

        Byte.database.updated_album_cover.connect ((album_id) => {
            if (album_id == album.id) {
                try {
                    cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id));
                    image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, 48, 48);
                } catch (Error e) {
                    stderr.printf ("Error setting default avatar icon: %s ", e.message);
                }
            }
        });
    }
}