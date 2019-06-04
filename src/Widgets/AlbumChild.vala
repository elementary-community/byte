public class Widgets.AlbumChild : Gtk.FlowBoxChild {
    public Objects.Album album { get; construct; }
    public string view_type { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_label;

    private Widgets.Cover image_cover;

    private string cover_path;
    public AlbumChild (Objects.Album album, string view_type) {
        Object (
            album: album,
            view_type: view_type
        );
    }

    construct {
        halign = Gtk.Align.START;
        tooltip_text = album.title;
        get_style_context ().add_class ("album-child");
        
        int pixel_size;
        int row_spacing;
        if (view_type == "album_view") {
            pixel_size = 48;
            row_spacing = 6;
        } else if (view_type == "home_view") {
            pixel_size = 32;
            row_spacing = 0;
        }


        title_label = new Gtk.Label (album.title);
        title_label.get_style_context ().add_class ("font-bold");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.max_width_chars = 20;
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.END;

        artist_label = new Gtk.Label (album.artist_name);
        artist_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        artist_label.max_width_chars = 20;
        artist_label.ellipsize = Pango.EllipsizeMode.END;
        artist_label.halign = Gtk.Align.START;
        artist_label.valign = Gtk.Align.START;

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Widgets.Cover.from_file (cover_path, pixel_size, "album");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.column_spacing = 6;
        main_grid.row_spacing = row_spacing;
        main_grid.halign = Gtk.Align.START;
        main_grid.valign = Gtk.Align.START;
        main_grid.attach (image_cover, 0, 0, 1, 2);
        main_grid.attach (title_label, 1, 0, 1, 1);
        main_grid.attach (artist_label, 1, 1, 1, 1);

        var event_box = new Gtk.EventBox ();
        event_box.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        event_box.add (main_grid);

        add (event_box);

        event_box.enter_notify_event.connect ((event) => {
            var select_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.HAND2);
            var window = Gdk.Screen.get_default ().get_root_window ();

            window.cursor = select_cursor;
            return false;
        });

        event_box.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            var select_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.ARROW);
            var window = Gdk.Screen.get_default ().get_root_window ();

            window.cursor = select_cursor;

            return false;
        });


        Byte.database.updated_album_cover.connect ((album_id) => {
            if (album_id == album.id) {
                cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id));
                image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, pixel_size, pixel_size);
            }
        });
    }
}
