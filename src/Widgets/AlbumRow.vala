public class Widgets.AlbumRow : Gtk.ListBoxRow {
    public Objects.Album album { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_label;

    public Gdk.Pixbuf cover_pixbuf;
    public AlbumRow (Objects.Album album) {
        Object (
            album: album
        );
    }

    construct {
        title_label = new Gtk.Label (album.title);
        title_label.get_style_context ().add_class ("font-bold");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.END;

        artist_label = new Gtk.Label (album.artist_name);
        artist_label.halign = Gtk.Align.START;

        string cover = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        var image_cover = new Granite.Widgets.Avatar.from_file (cover, 48);
        image_cover.get_style_context ().remove_class ("avatar");
        image_cover.get_style_context ().add_class ("cover");

        var cover_eventbox = new Gtk.EventBox ();
        cover_eventbox.visible_window = true;
        cover_eventbox.valign = Gtk.Align.CENTER;
        cover_eventbox.halign = Gtk.Align.CENTER;
        cover_eventbox.add (image_cover);

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.attach (cover_eventbox, 0, 0, 1, 2);
        main_grid.attach (title_label, 1, 0, 1, 1);
        main_grid.attach (artist_label, 1, 1, 1, 1);

        add (main_grid);
    }
}