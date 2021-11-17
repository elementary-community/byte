public class Widgets.SecionHeaderAction : Gtk.FlowBoxChild {
    public string title { get; construct; }
    public ViewType view { get; construct; }

    public SecionHeaderAction (string title, ViewType view) {
        Object (
            title: title,
            view: view,
            margin: 6
        );
    }

    construct {
        get_style_context ().add_class ("card");
        get_style_context ().add_class ("border-radius");

        var title_label = new Gtk.Label (title);
        title_label.get_style_context ().add_class ("font-bold");

        var arrow_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("byte-arrow-back-symbolic"),
            pixel_size = 16
        };
        arrow_icon.get_style_context ().add_class ("secion-header-iction");

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true,
            margin = 9
        };
        box.pack_start (title_label, false, true, 0);
        box.pack_end (arrow_icon, false, false, 0);

        add (box);
    }
}