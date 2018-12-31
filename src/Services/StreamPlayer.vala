public class Services.StreamPlayer : GLib.Object {
    private MainLoop loop;
    public dynamic Gst.Element player;
    public string state = "pause";
    public string n;

    private Gst.ClockTime duration = Gst.CLOCK_TIME_NONE;
    public StreamPlayer (string[]? args, string name) {
        if (args != null) {
            Gst.init (ref args);
        }

        if (name != null) {
            this.n = name;
        } else {
            this.n = "MAIN";
        }
    }

    private static inline bool GST_CLOCK_TIME_IS_VALID (Gst.ClockTime time) {
		return ((time) != Gst.CLOCK_TIME_NONE);
	}

    private bool bus_callback (Gst.Bus bus, Gst.Message message) {
        switch (message.type) {
            case Gst.MessageType.ERROR:
                GLib.Error err;
                string debug;

                message.parse_error (out err, out debug);
                stdout.printf ("Error: %s\n", err.message);
                loop.quit ();

                break;
            case Gst.MessageType.EOS:
                state = "endstream";
                break;
            case Gst.MessageType.STATE_CHANGED:
                Gst.State oldstate;
                Gst.State newstate;
                Gst.State pending;

                message.parse_state_changed (out oldstate, out newstate, out pending);

                break;
            case Gst.MessageType.DURATION_CHANGED :
                this.duration = Gst.CLOCK_TIME_NONE;
			    break;
            default:
                break;
        }

        return true;
    }

    public void ready_file (string stream) {
        pause_file ();

        player.set_state (Gst.State.NULL);
        player = Gst.ElementFactory.make ("playbin", "play");
        player.uri = stream;

        state = "pause";
        Gst.Bus bus = player.get_bus ();

        bus.add_watch (0, bus_callback);

        play_file ();
        int aux = 0;

        while (aux < 10000000) {
            aux = aux + 1;
        }

        pause_file ();
    }

    public void pause_file () {
        player.set_state (Gst.State.PAUSED);
        state = "pause";
    }

    public void play_file () {
        player.set_state (Gst.State.PLAYING);
        state = "play";
    }

    public ulong get_duration () {
        // Returns duration in nanoseconds
        if (!GST_CLOCK_TIME_IS_VALID (duration) && !player.query_duration (Gst.Format.TIME, out duration)) {
            stderr.puts ("Could not query current duration.\n");
            return (ulong) 0;
        }
        
        return (ulong) duration;
    }

    public ulong get_position () {
        // Returns position in nanoseconds
        int64 current = 0;
        if (!player.query_position (Gst.Format.TIME, out current)) {
            stderr.puts ("Could not query current position.\n");
        }
        return (ulong) current;
    }

    public void set_position(float fvalue) {
        player.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, (int64)(fvalue * get_duration ()));
    }
}
