public class Widgets.RadioSearchRow : Gtk.ListBoxRow {
    public Objects.Radio radio { get; construct; }

    private Gtk.Label name_label;
    private Gtk.Label country_state_label;
    private Widgets.Cover image_cover;

    public signal void send_notification_error ();

    public RadioSearchRow (Objects.Radio radio) {
        Object (
            radio: radio
        );
    }

    construct {
        get_style_context ().add_class ("radio-search-row");
        tooltip_text = radio.name;

        name_label = new Gtk.Label (radio.name);
        name_label.margin_end = 6;
        name_label.get_style_context ().add_class ("font-bold");
        name_label.ellipsize = Pango.EllipsizeMode.END;
        name_label.halign = Gtk.Align.START;
        name_label.valign = Gtk.Align.END;

        country_state_label = new Gtk.Label ("%s - %s".printf (radio.country, radio.state));
        country_state_label.halign = Gtk.Align.START;
        country_state_label.valign = Gtk.Align.START;
        country_state_label.max_width_chars = 45;
        country_state_label.ellipsize = Pango.EllipsizeMode.END;

        image_cover = new Widgets.Cover.from_url_async (radio.favicon, 32, true, "radio");

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_button.get_style_context ().add_class ("quick-find-add-radio");
        add_button.hexpand = true;
        add_button.halign = Gtk.Align.END;
        add_button.valign = Gtk.Align.CENTER;

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.margin_end = 6;
        main_grid.column_spacing = 6;
        main_grid.attach (image_cover, 0, 0, 1, 2);
        main_grid.attach (name_label, 1, 0, 1, 1);
        main_grid.attach (country_state_label, 1, 1, 1, 1);
        main_grid.attach (add_button, 2, 0, 2, 2);

        add (main_grid);

        add_button.clicked.connect (() => {
            if (Byte.database.radio_exists (radio.url)) {
                send_notification_error ();
            } else {
                Byte.database.insert_radio (radio);
            }
        });
    }
}