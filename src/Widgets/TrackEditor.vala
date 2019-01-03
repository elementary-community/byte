public class Widgets.TrackEditor : Gtk.EventBox {
    public signal void on_signal_back_button ();
    public Objects.Track track {
        set {

        }
    }

    public TrackEditor () {
        Object (

        );
    }

    construct {
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.can_focus = false;
        back_button.valign = Gtk.Align.CENTER;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Track Editor")));
        title_label.use_markup = true;

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.margin = 6;
        top_box.hexpand = true;
        top_box.pack_start (back_button, false, false, 0);
        top_box.set_center_widget (title_label);

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.add (top_box);
        main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        add (main_grid);

        back_button.clicked.connect (() => {
            on_signal_back_button ();
        });
    }
}
