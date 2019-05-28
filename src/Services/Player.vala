public class Services.Player : GLib.Object {
    public signal void state_changed (Gst.State state);
    public signal void current_progress_changed (double percent);
    public signal void current_duration_changed (int64 duration);
    public signal void current_track_changed (Objects.Track? track);
    
    public signal void toggle_playing (); 

    uint progress_timer = 0;

    public Objects.Track? current_track { get; set; }

    Gst.Format fmt = Gst.Format.TIME;
    dynamic Gst.Element playbin;
    Gst.Bus bus;

    public unowned int64 duration {
        get {
            int64 d = 0;
            playbin.query_duration (fmt, out d);
            return d;
        }
    }

    public unowned int64 position {
        get {
            int64 d = 0;
            playbin.query_position (fmt, out d);
            return d;
        }
    }

    public double target_progress { get; set; default = 0; }

    public Player () {
        playbin = Gst.ElementFactory.make ("playbin", "play");

        bus = playbin.get_bus ();
        bus.add_watch (0, bus_callback);
        bus.enable_sync_message_emission ();

        state_changed.connect ((state) => {
            stop_progress_signal ();

            if (state != Gst.State.NULL) {
                playbin.set_state (state);
            }
            
            switch (state) {
                case Gst.State.PLAYING:
                    start_progress_signal ();
                    break;
                case Gst.State.READY:
                    stop_progress_signal (true);
                    break;
                case Gst.State.PAUSED:
                    pause_progress_signal ();
                    break;
            }
        });
    }
    
    public bool load_track (Objects.Track? track, double progress = 0) {
        if (track == current_track || track == null) {
            return false;
        }

        current_track = track;
        
        var last_state = get_state ();
        stop ();

        playbin.uri = current_track.path;
        playbin.set_state (Gst.State.PLAYING);
        state_changed (Gst.State.PLAYING);

        while (duration == 0) {};

        if (last_state != Gst.State.PLAYING) {
            pause ();
        }
        current_duration_changed (duration);

        if (progress > 0) {
            seek_to_progress (progress);
            current_progress_changed (progress);
        }
        
        return true;
    }
    
    public void set_track (Objects.Track? track) {
        if (track == null) {
            current_duration_changed (0);
        }

        if (load_track (track)) {
            play ();

            current_track_changed (track);
            Byte.notification.send_notification (track);
        }
    }

    public void seek_to_position (int64 position) {
        playbin.seek_simple (fmt, Gst.SeekFlags.FLUSH, position);
    }

    public void seek_to_progress (double percent) {
        seek_to_position ((int64)(percent * duration));
    }

    private unowned int64 get_position_sec () {
        int64 current = position;
        return current > 0 ? current / Gst.SECOND : -1;
    }
    
    public unowned double get_position_progress () {
        return (double) 1 / duration * position;
    }

    public Gst.State get_state () {
        Gst.State state = Gst.State.NULL;
        Gst.State pending;
        playbin.get_state (out state, out pending, (Gst.ClockTime) (Gst.SECOND));
        return state;
    }

    public void pause_progress_signal () {
        if (progress_timer != 0) {
            Source.remove (progress_timer);
            progress_timer = 0;
        }
    }
    
    public void stop_progress_signal (bool reset_timer = false) {
        pause_progress_signal ();
        if (reset_timer) {
            current_progress_changed (0);
        }
    }

    public void start_progress_signal () {
        pause_progress_signal ();
        progress_timer = GLib.Timeout.add (250, () => {
            current_progress_changed (get_position_progress ());
            return true;
        });
    }
    
    public void play () {
        if (current_track != null) {
            state_changed (Gst.State.PLAYING);
        }
    }

    public void pause () {
        state_changed (Gst.State.PAUSED);
    }

    public void stop () {
        state_changed (Gst.State.READY);
    }

    public void next () {
        var repeat_mode = Byte.settings.get_enum ("repeat-mode");
        var shuffle_mode = Byte.settings.get_boolean ("shuffle-mode");

        if (current_track == null) {
            return;
        }

        Objects.Track? next_track = null;

        if (repeat_mode == 2) {
            next_track = current_track;
            current_track = null;
        } else {
            if (shuffle_mode) {
                next_track = Byte.utils.get_next_shuffle_track ();
            } else {
                next_track = Byte.utils.get_next_track ();
            }
        }

        if (next_track != null) {
            set_track (next_track);
        } else {
            state_changed (Gst.State.NULL);
        }
    }

    public void prev () {
        var repeat_mode = Byte.settings.get_enum ("repeat-mode");
        var shuffle_mode = Byte.settings.get_boolean ("shuffle-mode");
        
        if (current_track == null) {
            return;
        }

        if (get_position_sec () < 1) {
            Objects.Track? prev_track = null;

            if (shuffle_mode) {
                prev_track = Byte.utils.get_prev_shuffle_track ();
            } else {
                prev_track = Byte.utils.get_prev_track ();
            }
            
            if (prev_track != null) {
                set_track (prev_track);
            }
        } else {
            stop ();
            play ();
        }
    }

    private bool bus_callback (Gst.Bus bus, Gst.Message message) {
        switch (message.type) {
            case Gst.MessageType.ERROR:
                GLib.Error err;
                string debug;
                message.parse_error (out err, out debug);
                warning ("Error: %s\n%s\n", err.message, debug);
                break;
            case Gst.MessageType.EOS:
                next ();
                break;
            default:
                break;
            }

        return true;
    }
}
