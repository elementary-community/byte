public class Widgets.Queue : Gtk.Revealer {
    private Widgets.Cover image_cover;
    private Gtk.Button view_button;

    private Gtk.ListBox queue_listbox;
    public Queue () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        valign = Gtk.Align.END;
        halign = Gtk.Align.CENTER;
        reveal_child = false;
        transition_duration = 300;
    }

    construct {
        image_cover = new Widgets.Cover.with_default_icon (24);

        var view_button = new Gtk.Button.with_label (_("View all"));
        view_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        view_button.get_style_context ().add_class ("button-color");
        view_button.can_focus = false;
        view_button.valign = Gtk.Align.CENTER;

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.pack_start (image_cover, false, false, 0);
        top_box.pack_end (view_button, false, false, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 6;
        main_box.width_request = 325;
        main_box.get_style_context ().add_class ("queue");
        main_box.pack_start (top_box, false, false, 0);

        add (main_box);
    }
}