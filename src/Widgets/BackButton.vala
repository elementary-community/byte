public class Widgets.BackButton : Gtk.Button {
    construct {
        can_focus = false;
        get_style_context ().add_class ("back-section-button");

        var arrow_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("pan-start-symbolic"),
            pixel_size = 16
        };

        var title_label = new Gtk.Label (_("Back"));

        var box = new Gtk.Grid () {
            margin_end = 6
        };
        box.add (arrow_icon);
        box.add (title_label);

        add (box);
    }
}