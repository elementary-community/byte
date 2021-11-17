public class Objects.Track : GLib.Object {
    public int ID { get; set; default = 0; }
    public string title { get; set; default = ""; }
    public string genre { get; set; default = ""; }
    public int track { get; set; default = 0; }
    public int disc { get; set; default = 0; }
    public uint64 duration { get; set; default = 0; }
    public string date_added { get; set; default = new GLib.DateTime.now_local ().to_string (); }

    string _uri = "";
    public string uri {
        get {
            return _uri;
        } set {
            _uri = value;
        }
    }

    Objects.Album ? _album = null;
    public Objects.Album album {
        get {
            if (_album == null) {
                _album = Byte.database_manager.get_album_by_track_id (this.ID);
            }
            return _album;
        }
    }

    string ? _cover_path = null;
    public string ? cover_path {
        get {
            _cover_path = GLib.Path.build_filename (
                Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte/covers",
                ("album-%i.jpg").printf (album.ID)
            );

            var file = File.new_for_uri (_cover_path);
            if (!file.query_exists ()) {
                
            }
            file.dispose ();

            return _cover_path;
        }
    }

    public signal void album_changed (Objects.Album album);

    public Track (Objects.TracksContainer ? container = null) {
        if (container != null && container is Objects.Album) {
            set_album (container as Objects.Album);
        }
    }

    public void set_album (Objects.Album album) {
        _album = album;
        album_changed (album);
    }

    public Gdk.Pixbuf? get_pixbuf (int size) {
        try {
            return new Gdk.Pixbuf.from_file_at_scale (cover_path, size, size, true);
        } catch (Error e) {
            return null;
        }
    }
}