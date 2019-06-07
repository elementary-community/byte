public class Widgets.HeaderBar : Gtk.HeaderBar {
    private Gtk.Box main_box;

    private Gtk.Button shuffle_button;
    private Gtk.Button repeat_button;
    private Gtk.Button play_button;
    private Gtk.Button next_button;
    private Gtk.Button previous_button;
    private Gtk.Button search_button;

    private Gtk.Image icon_play;
    private Gtk.Image icon_pause;

    private Gtk.Image icon_shuffle_on;
    private Gtk.Image icon_shuffle_off;

    private Gtk.Image icon_repeat_one;
    private Gtk.Image icon_repeat_all;
    private Gtk.Image icon_repeat_off;

    public signal void show_quick_find ();
    public bool visible_ui {
        set {
            main_box.visible = value;
            search_button.visible = value;

            if (value) {
                custom_title = main_box;
            } else {
                custom_title = null;
            }
        }
    }

    public HeaderBar () {
        Object (
            show_close_button: true
        );
    }

    construct {
        icon_play = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        icon_pause = new Gtk.Image.from_icon_name ("media-playback-pause-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

        icon_shuffle_on = new Gtk.Image.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.BUTTON);
        icon_shuffle_off = new Gtk.Image.from_icon_name ("media-playlist-no-shuffle-symbolic", Gtk.IconSize.BUTTON);

        icon_repeat_one = new Gtk.Image.from_icon_name ("media-playlist-repeat-one-symbolic", Gtk.IconSize.BUTTON);
        icon_repeat_all = new Gtk.Image.from_icon_name ("media-playlist-repeat-symbolic", Gtk.IconSize.BUTTON);
        icon_repeat_off = new Gtk.Image.from_icon_name ("media-playlist-no-repeat-symbolic", Gtk.IconSize.BUTTON);

        get_style_context ().add_class ("default-decoration");
        decoration_layout = "close:menu";

        // Shuffle Button
        shuffle_button = new Gtk.Button ();
        shuffle_button.get_style_context ().add_class ("repeat-button");
        shuffle_button.get_style_context ().remove_class ("button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        shuffle_button.valign = Gtk.Align.CENTER;
        shuffle_button.can_focus = false;

        // Previous Button
        previous_button = new Gtk.Button.from_icon_name ("media-skip-backward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        previous_button.valign = Gtk.Align.CENTER;
        previous_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        previous_button.can_focus = false;
        previous_button.tooltip_text = _ ("Previous");

        play_button = new Gtk.Button ();
        play_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        play_button.can_focus = false;
        play_button.valign = Gtk.Align.CENTER;
        play_button.image = icon_play;
        play_button.tooltip_text = _ ("Play");

        // Next Button
        next_button = new Gtk.Button.from_icon_name ("media-skip-forward-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        next_button.valign = Gtk.Align.CENTER;
        next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        next_button.can_focus = false;
        next_button.tooltip_text = _ ("Next");

        // Repeat Button
        repeat_button = new Gtk.Button ();
        repeat_button.valign = Gtk.Align.CENTER;
        repeat_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        repeat_button.can_focus = false;

        search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.valign = Gtk.Align.CENTER;
        search_button.can_focus = false;
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        main_box.pack_start (repeat_button, false, false, 24);
        main_box.pack_start (previous_button, false, false, 0);
        main_box.pack_start (play_button, false, false, 0);
        main_box.pack_start (next_button, false, false, 0);
        main_box.pack_start (shuffle_button, false, false, 24);
        
        custom_title = main_box;
        pack_end (search_button);

        check_shuffle_button ();
        check_repeat_button ();

        play_button.clicked.connect (() => {
            toggle_playing ();
        });

        Byte.player.state_changed.connect ((state) => {
            if (state == Gst.State.PLAYING) {
                play_button.image = icon_pause;
            } else {
                play_button.image = icon_play;
            }
        });

        shuffle_button.clicked.connect (() => {
            Byte.settings.set_boolean ("shuffle-mode", !Byte.settings.get_boolean ("shuffle-mode"));
        });

        repeat_button.clicked.connect (() => {
            var enum = Byte.settings.get_enum ("repeat-mode");

            if (enum == 1) {
                Byte.settings.set_enum ("repeat-mode", 2);
            } else if (enum == 2) {
                Byte.settings.set_enum ("repeat-mode", 0);
            } else {
                Byte.settings.set_enum ("repeat-mode", 1);
            }
        });

        previous_button.clicked.connect (() => {
            Byte.player.prev ();
        });

        next_button.clicked.connect (() => {
            Byte.player.next ();
        });

        Byte.settings.changed.connect ((key) => {
            if (key == "shuffle-mode") {
                check_shuffle_button ();
            } else if (key == "repeat-mode") {
                check_repeat_button ();
            }   
        });

        Byte.player.toggle_playing.connect (() => {
            toggle_playing ();
        });

        search_button.clicked.connect (() => {
            show_quick_find ();
        });
    }

    public void toggle_playing () {
        if (play_button.image == icon_play) {
            play_button.image = icon_pause;
            Byte.player.state_changed (Gst.State.PLAYING);
        } else {
            play_button.image = icon_play;
            Byte.player.state_changed (Gst.State.PAUSED);
        }
    }

    private void check_shuffle_button () {
        if (Byte.settings.get_boolean ("shuffle-mode")) {
            shuffle_button.image = icon_shuffle_on;
            shuffle_button.tooltip_text = _ ("Shuffle On");
        } else {
            shuffle_button.image = icon_shuffle_off;
            shuffle_button.tooltip_text = _ ("Shuffle Off");
        }
    }

    private void check_repeat_button () {
        var repeat_mode = Byte.settings.get_enum ("repeat-mode");

        if (repeat_mode == 0) {
            repeat_button.image = icon_repeat_off;
            repeat_button.tooltip_text = _ ("Repeat Off");
        } else if (repeat_mode == 1) {
            repeat_button.image = icon_repeat_all;
            repeat_button.tooltip_text = _ ("Repeat All");
        } else {
            repeat_button.image = icon_repeat_one;
            repeat_button.tooltip_text = _ ("Repeat One");
        }

        repeat_button.show_all ();
    }
}
