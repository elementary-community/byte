public class Widgets.AlbumImage : Gtk.Grid {
    public int size { get; construct; }
    private Gtk.Image image;
    
    public AlbumImage (int size) {
        Object (
            size: size
        );
    }

    construct {
        get_style_context ().add_class ("album");
        get_style_context ().add_class (Granite.STYLE_CLASS_CARD);

        image = new Gtk.Image () {
            height_request = size,
            width_request = size,
            pixel_size = size
        };

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        height_request = size;
        width_request = size;
        add (image);
    }

    public void set_pixbuf (Gdk.Pixbuf? pixbuf) {
        if (pixbuf != null) {
            image.pixbuf = pixbuf;
        }
    }
}