public class Widgets.AlbumRow : Gtk.ListBoxRow {
    public Objects.Album album { get; construct; }

    private Gtk.Label primary_label;
    private Gtk.Label secondary_label;

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

        primary_label = new Gtk.Label (album.title);
        primary_label.get_style_context ().add_class ("font-bold");
        primary_label.ellipsize = Pango.EllipsizeMode.END;
        primary_label.halign = Gtk.Align.START;
        primary_label.max_width_chars = 45;
        primary_label.valign = Gtk.Align.END;

        secondary_label = new Gtk.Label (null);
        secondary_label.halign = Gtk.Align.START;
        secondary_label.valign = Gtk.Align.START;
        secondary_label.ellipsize = Pango.EllipsizeMode.END;

        int _value = Byte.settings.get_enum ("album-sort");
        if (_value == 0) {
            secondary_label.label = "%s - %s".printf (album.artist_name, album.title);
        } else if (_value == 1) {
            secondary_label.label = "%s - %s".printf (album.artist_name, album.title);
        } else if (_value == 2) {
            secondary_label.label = "%s - %i".printf (album.artist_name, album.year);
        } else if (_value == 3) {
            secondary_label.label = "%s - %s".printf (album.artist_name, album.genre);
        }
        
        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Widgets.Cover.from_file (cover_path, 48, "album");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = 3;
        main_grid.attach (image_cover, 0, 0, 1, 2);
        main_grid.attach (primary_label, 1, 0, 1, 1);
        main_grid.attach (secondary_label, 1, 1, 1, 1);

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