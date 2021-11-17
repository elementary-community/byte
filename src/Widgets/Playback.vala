public class Widgets.Playback : Gtk.Revealer {
    private Hdy.Avatar cover;
    private Gtk.Label title_label;
    private Gtk.Label artist_label;

    public Gtk.Image icon_play;
    public Gtk.Image icon_pause;
    public Gtk.Image icon_stop;

    public Gtk.Button previous_button;
    public Gtk.Button play_button;
    public Gtk.Button next_button;
    public Playback () {
        Object (
            transition_type: Gtk.RevealerTransitionType.SLIDE_UP,
            valign: Gtk.Align.END,
            reveal_child: false
        );
    }

    construct {
        icon_play = new Gtk.Image () {
            gicon = new ThemedIcon ("media-playback-start-symbolic"),
            pixel_size = 20
        };

        icon_pause = new Gtk.Image () {
            gicon = new ThemedIcon ("media-playback-pause-symbolic"),
            pixel_size = 20
        };

        icon_stop = new Gtk.Image () {
            gicon = new ThemedIcon ("media-playback-stop-symbolic"),
            pixel_size = 20
        };

        var cover = new Widgets.AlbumImage (32);
        
        title_label = new Gtk.Label (null) {
            halign = Gtk.Align.START
        };
        title_label.get_style_context ().add_class ("font-bold");
        artist_label = new Gtk.Label (null) {
            halign = Gtk.Align.START
        };

        var previous_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("media-skip-backward-symbolic"),
            pixel_size = 16
        };  

        previous_button = new Gtk.Button ();
        previous_button.image = previous_icon;
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

        var next_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("media-skip-forward-symbolic"),
            pixel_size = 16
        }; 

        next_button = new Gtk.Button ();
        next_button.image = next_icon;
        next_button.valign = Gtk.Align.CENTER;
        next_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        next_button.can_focus = false;
        next_button.tooltip_text = _ ("Next");

        var action_grid = new Gtk.Grid () {
            hexpand = true,
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER
        };
        action_grid.add (previous_button);
        action_grid.add (play_button);
        action_grid.add (next_button);

        var content = new Gtk.Grid () {
            column_spacing = 6,
            margin = 6
        };
        content.attach (cover, 0, 0, 1, 2);
        content.attach (title_label, 1, 0, 1, 1);
        content.attach (artist_label, 1, 1, 1, 1);
        content.attach (action_grid, 2, 0, 2, 2);

        var main_content = new Gtk.Grid () {
            margin = 6
        };
        main_content.get_style_context ().add_class ("border-radius");
        main_content.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        main_content.add (content);

        add (main_content);

        Byte.playback_manager.current_track_changed.connect ((track) => {
            cover.set_pixbuf (track.get_pixbuf (32));
            title_label.label = track.title;
            artist_label.label = track.album.artist.name;
        });

        Byte.playback_manager.state_changed.connect ((state) => {
            if (state == Gst.State.PLAYING) {
                reveal_child = true;
                play_button.image = icon_pause;
            } else {
                play_button.image = icon_play;
            }
        });

        play_button.clicked.connect (() => {
            Byte.playback_manager.toggle_playing ();
        });

        Byte.playback_manager.toggle_playing.connect (toggle_playing);
    }

    public void toggle_playing () {
        if (play_button.image == icon_play) {
            play_button.image = icon_pause;
            Byte.playback_manager.state_changed (Gst.State.PLAYING);
        } else if (play_button.image == icon_pause) {
            play_button.image = icon_play;
            Byte.playback_manager.state_changed (Gst.State.PAUSED);
        } else {
            // Byte.player.current_radio = null;
            play_button.image = icon_play;
            Byte.playback_manager.state_changed (Gst.State.READY);
        }
    }
}