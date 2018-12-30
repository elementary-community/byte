public class Widgets.HeaderBar : Gtk.HeaderBar {
    public weak Gtk.Window window { get; construct; }
    public int repeat_index = 0;

    public HeaderBar (Gtk.Window parent) {
        Object (
            window: parent,
            show_close_button: true
        );
    }

    construct {
        get_style_context ().add_class ("default-decoration");
        decoration_layout = "close:menu";

        var shuffle_button = new Gtk.ToggleButton ();
        shuffle_button.get_style_context ().add_class ("repeat-button");
        shuffle_button.get_style_context ().remove_class ("button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        shuffle_button.valign = Gtk.Align.CENTER;
        shuffle_button.can_focus = false;

        var shuffle_icon = new Gtk.Image ();
        shuffle_icon.gicon = new ThemedIcon ("media-playlist-consecutive-symbolic");
        shuffle_icon.pixel_size = 16;

        shuffle_button.add (shuffle_icon);

        var backward_button = new Gtk.Button.from_icon_name ("media-seek-backward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        backward_button.can_focus = false;

        var playback_button = new Gtk.ToggleButton ();
        playback_button.get_style_context ().add_class ("repeat-button");
        playback_button.get_style_context ().remove_class ("button");
        playback_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        playback_button.valign = Gtk.Align.CENTER;
        playback_button.can_focus = false;

        var playback_icon = new Gtk.Image ();
        playback_icon.gicon = new ThemedIcon ("media-playback-start-symbolic");
        playback_icon.pixel_size = 24;

        playback_button.add (playback_icon);

        var forward_button = new Gtk.Button.from_icon_name ("media-seek-forward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        forward_button.can_focus = false;

        var repeat_button = new Gtk.Button.from_icon_name ("media-playlist-repeat-symbolic", Gtk.IconSize.MENU);
        repeat_button.opacity = 0.7;
        repeat_button.valign = Gtk.Align.CENTER;
        repeat_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        repeat_button.can_focus = false;

        var eq_button = new Gtk.Button.from_icon_name ("media-eq-symbolic", Gtk.IconSize.MENU);
        eq_button.can_focus = false;

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.spacing = 6;
        main_box.pack_start (shuffle_button, false, false, 24);
        main_box.pack_start (backward_button, false, false, 0);
        main_box.pack_start (playback_button, false, false, 0);
        main_box.pack_start (forward_button, false, false, 0);
        main_box.pack_start (repeat_button, false, false, 24);

        custom_title = main_box;
        pack_end (eq_button);

        shuffle_button.toggled.connect (() => {
            if (shuffle_button.active) {
                shuffle_icon.icon_name = "media-playlist-shuffle-symbolic";
            } else {
                shuffle_icon.icon_name = "media-playlist-consecutive-symbolic";
            }
        });

        playback_button.toggled.connect (() => {
            if (playback_button.active) {
                playback_icon.icon_name = "media-playback-pause-symbolic";

                Application.signals.play_track ();
            } else {
                playback_icon.icon_name = "media-playback-start-symbolic";

                Application.signals.pause_track ();
            }
        });

        repeat_button.clicked.connect (() => {
            repeat_index = repeat_index + 1;

            if (repeat_index > 2) {
                repeat_index = 0;
            }

            if (repeat_index == 0) {
                repeat_button.image = new Gtk.Image.from_icon_name ("media-playlist-repeat-symbolic", Gtk.IconSize.MENU);
                repeat_button.opacity = 0.7;
            } else if (repeat_index == 1) {
                repeat_button.image = new Gtk.Image.from_icon_name ("media-playlist-repeat-symbolic", Gtk.IconSize.MENU);
                repeat_button.opacity = 1;
            } else {
                repeat_button.image = new Gtk.Image.from_icon_name ("media-playlist-repeat-song-symbolic", Gtk.IconSize.MENU);
                repeat_button.opacity = 1;
            }
        });
    }
}
