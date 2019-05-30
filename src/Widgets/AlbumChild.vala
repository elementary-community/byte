public class Widgets.AlbumChild : Gtk.FlowBoxChild {
    public Objects.Album album { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_label;

    private Granite.Widgets.Avatar image_cover;

    private string cover_path;
    public AlbumChild (Objects.Album album) {
        Object (
            album: album
        );
    }

    construct {
        tooltip_text = album.title;
        get_style_context ().add_class ("album-child");
        //halign = Gtk.Align.CENTER;

        title_label = new Gtk.Label (album.title);
        title_label.get_style_context ().add_class ("font-bold");
        title_label.margin_start = 3;
        title_label.margin_top = 3;
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.halign = Gtk.Align.CENTER;
        title_label.valign = Gtk.Align.START;

        artist_label = new Gtk.Label (album.artist_name);
        artist_label.margin_start = 3;
        artist_label.halign = Gtk.Align.CENTER;
        artist_label.valign = Gtk.Align.START;

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Granite.Widgets.Avatar.from_file (cover_path, 64);
        image_cover.halign = Gtk.Align.CENTER;
        image_cover.valign = Gtk.Align.START;
        image_cover.get_style_context ().remove_class ("avatar");
        image_cover.get_style_context ().add_class ("cover");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin = 3;
        main_box.halign = Gtk.Align.CENTER;
        main_box.valign = Gtk.Align.START;
        main_box.pack_start (image_cover, false, false, 0);
        main_box.pack_start (title_label, false, false, 0);
        main_box.pack_start (artist_label, false, false, 0);

        add (main_box);

        Byte.database.updated_album_cover.connect ((album_id) => {
            if (album_id == album.id) {
                cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id));
                image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, 64, 64);
            }
        });
    }
}
