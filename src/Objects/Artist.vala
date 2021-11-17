public class Objects.Artist : Objects.TracksContainer {
    public new GLib.List<Track> tracks {
        get {
            if (_tracks == null) {
                _tracks = Byte.database_manager.get_track_collection (this);
            }
            return _tracks;
        }
    }

    GLib.List<Album> _albums;
    public GLib.List<Objects.Album> albums {
        get {
            if (_albums == null) {
                _albums = new GLib.List<Objects.Album> ();
                foreach (var album in Byte.database_manager.get_album_collection (this)) {
                    add_album (album);
                }
            }
            return _albums;
        }
    }

    public Objects.Album add_album_if_not_exists (Objects.Album new_album) {
        Objects.Album? return_value = null;
        lock (_albums) {
            return_value = get_album_by_title (new_album.title);
            if (return_value == null) {
                new_album.set_artist (this);
                add_album (new_album);
                Byte.database_manager.insert_album (new_album);
                return_value = new_album;
            }
            return return_value;
        }
    }

    public Objects.Album? get_album_by_title (string title) {
        Objects.Album? return_value = null;
        lock (_albums) {
            foreach (var album in albums) {
                if (album.title == title) {
                    return_value = album;
                    break;
                }
            }
        }
        return return_value;
    }

    public void add_album (Objects.Album album) {
        this._albums.append (album);
        if (album.artist_track_added_signal_id == 0) {
           album.artist_track_added_signal_id = album.track_added.connect (add_track);
           foreach (var track in album.tracks) {
                add_track (track);
           }
        }
    }
}
