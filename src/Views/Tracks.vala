public class Views.Tracks : Gtk.EventBox {
    construct {
        var back_button = new Widgets.BackButton () {
            halign = Gtk.Align.START
        };

        var title_label = new Gtk.Label (_("Tracks")) {
            margin_top = 12,
            halign = Gtk.Align.START
        };
        title_label.get_style_context ().add_class ("h2");
        title_label.get_style_context ().add_class ("font-bold");

        var number_label = new Gtk.Label (_("34 Songs"));
        number_label.get_style_context ().add_class ("small-label");
        
        var arrow_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("byte-arrow-back-symbolic"),
            pixel_size = 9
        };
        arrow_icon.yalign = (float) 0.8;
        arrow_icon.get_style_context ().add_class ("arrow-icon");

        var number_grid = new Gtk.Grid () {
            valign = Gtk.Align.CENTER,
            margin_start = 3,
            column_spacing = 6
        };
        number_grid.add (number_label);
        number_grid.add (arrow_icon);

        var filter_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("byte-arrow-back-symbolic"),
            pixel_size = 16
        };
        var filter_button = new Gtk.Button ();
        filter_button.can_focus = false;
        filter_button.image = filter_icon;

        var action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true,
            margin_top = 6
        };

        action_box.pack_start (number_grid, false, false, 0);
        // action_box.pack_end (filter_button, false, false, 0);

        var main_grid = new Gtk.Grid () {
            margin = 12,
            orientation = Gtk.Orientation.VERTICAL
        };

        main_grid.add (back_button);
        main_grid.add (title_label);
        main_grid.add (action_box);

        add (main_grid);
    }
}