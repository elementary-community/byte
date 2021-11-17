public class Objects.TracksContainer : GLib.Object {
    public signal void cover_changed ();

    public string title { get; set; default = ""; }
    public string name { get; set; default = ""; }
    public string date_added { get; set; default = new GLib.DateTime.now_local ().to_string (); }
    
    protected int _ID = 0;
    public int ID {
        get {
            return _ID;
        } set {
            _ID = value;
        }
    }
    protected GLib.List<Objects.Track> _tracks = null;

    public signal void track_added (Objects.Track track);
    public signal void track_removed (Objects.Track track);
    
    public string cover_path { get; protected set; default = ""; }
    protected bool is_cover_loading = false;
    public ulong artist_track_added_signal_id { get; set; default = 0; }

    public Gdk.Pixbuf ? cover_32 { get; private set; }

    Gdk.Pixbuf ? _cover = null;
    public Gdk.Pixbuf ? cover {
        get {
            return _cover;
        } protected set {
            _cover = value;
            cover_32 = value.scale_simple (32, 32, Gdk.InterpType.BILINEAR);
            cover_changed ();
        }
    }

    protected void add_track (Objects.Track track) {
        if (has_track (track)) {
            return;
        }
        lock (_tracks) {
            // this._tracks.insert_sorted_with_data (track, sort_function);
        }
        track_added (track);
    }

    protected bool has_track (Objects.Track track) {
        bool return_value = false;
        lock (_tracks) {
            if (_tracks != null) {
                foreach (var t in _tracks) {
                    if (t.uri == track.uri) {
                        return_value = true;
                        break;
                    }
                }
            }
        }
        return return_value;
    }

    protected Gdk.Pixbuf ? save_cover (Objects.Track track, Gdk.Pixbuf p, int size) {
        Gdk.Pixbuf ? pixbuf = align_and_scale_pixbuf (p, size);
        try {
            cover_path = GLib.Path.build_filename (
                Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte/covers",
                ("album-%i.jpg").printf (track.album.ID)
            );

            print ("COVER: %s".printf (cover_path));

            pixbuf.save (cover_path, "jpeg", "quality", "100");
        } catch (Error err) {
            warning (err.message);
        }
        return pixbuf;
    }

    public Gdk.Pixbuf ? align_and_scale_pixbuf (Gdk.Pixbuf p, int size) {
        Gdk.Pixbuf ? pixbuf = p;
        if (pixbuf.width != pixbuf.height) {
            if (pixbuf.width > pixbuf.height) {
                int dif = (pixbuf.width - pixbuf.height) / 2;
                pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, dif, 0, pixbuf.height, pixbuf.height);
            } else {
                int dif = (pixbuf.height - pixbuf.width) / 2;
                pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, 0, dif, pixbuf.width, pixbuf.width);
            }
        }
        pixbuf = pixbuf.scale_simple (size, size, Gdk.InterpType.BILINEAR);
        return pixbuf;
    }
}