public class Widgets.FolderRow : Gtk.ListBoxRow {
    public Objects.Track track { get; set; }

    public string title { get; construct; }
    public string uri { get; construct; }

    public FolderRow (string title, string uri) {
        Object (
            title: title,
            uri: uri
        );
    }

    construct {
        get_style_context ().add_class ("album-row");

        var folder_image = new Gtk.Image ();
        folder_image.gicon = new ThemedIcon ("byte-folder");
        folder_image.pixel_size = 35;

        var folder_label = new Gtk.Label (title);
        folder_label.get_style_context ().add_class ("font-bold");
        folder_label.ellipsize = Pango.EllipsizeMode.END;
        folder_label.halign = Gtk.Align.START;
        folder_label.max_width_chars = 45;
        folder_label.valign = Gtk.Align.CENTER;
        folder_label.margin_top = 9;

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.margin_start = 6;
        main_grid.column_spacing = 6;
        main_grid.add (folder_image);
        main_grid.add (folder_label);

        add (main_grid);
    }
}