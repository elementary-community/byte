public class Widgets.SectionHeader : Gtk.EventBox {
    public string title { get; construct; }
    public bool show_button { get; construct; }

    public SectionHeader (string title, bool show_button=true) {
        Object (
            title: title,
            show_button: show_button
        );
    }

    construct {
        var title_label = new Gtk.Label (title) {
            halign = Gtk.Align.START
        };
        title_label.get_style_context ().add_class ("h3");
        title_label.get_style_context ().add_class ("font-bold");

        var show_button = new Gtk.Button.with_label (_("Show all")) {
            halign = Gtk.Align.END,
            no_show_all = !show_button
        };
        show_button.get_style_context ().add_class ("primary-color");
        show_button.get_style_context ().add_class ("flat");

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true
        };

        main_box.pack_start (title_label);
        main_box.pack_end (show_button);

        add (main_box);
    }
}