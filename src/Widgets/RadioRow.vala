public class Widgets.RadioRow : Gtk.ListBoxRow {
    public Objects.Radio radio { get; construct; }

    private Gtk.Label name_label;
    private Gtk.Label country_state_label;
    private Widgets.Cover image_cover;

    public signal void send_notification_error ();

    public RadioRow (Objects.Radio radio) {
        Object (
            radio: radio
        );
    }

    construct {
        get_style_context ().add_class ("track-row");
        tooltip_text = radio.name;

        var playing_icon = new Gtk.Image ();
        playing_icon.gicon = new ThemedIcon ("audio-volume-medium-symbolic");
        playing_icon.get_style_context ().add_class ("playing-ani-color");
        playing_icon.pixel_size = 16;

        var playing_revealer = new Gtk.Revealer ();
        playing_revealer.halign = Gtk.Align.CENTER;
        playing_revealer.valign = Gtk.Align.CENTER;
        playing_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        playing_revealer.add (playing_icon);
        playing_revealer.reveal_child = false;

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

        var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("radio-%i.jpg").printf (radio.id));
        image_cover = new Widgets.Cover.from_file (cover_path, 48, "radio");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        var overlay = new Gtk.Overlay ();
        overlay.halign = Gtk.Align.START;
        overlay.valign = Gtk.Align.START;
        overlay.add_overlay (playing_revealer);
        overlay.add (image_cover); 

        var main_grid = new Gtk.Grid ();
        main_grid.margin = 3;
        main_grid.margin_end = 6;
        main_grid.column_spacing = 6;
        main_grid.attach (overlay, 0, 0, 1, 2);
        main_grid.attach (name_label, 1, 0, 1, 1);
        main_grid.attach (country_state_label, 1, 1, 1, 1);

        add (main_grid);

        Byte.player.current_radio_changed.connect ((current_radio) => {
            if (radio.id == current_radio.id) {
                playing_revealer.reveal_child = true;
            } else {
                playing_revealer.reveal_child = false;
            }
        });
    }
}