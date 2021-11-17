public class Objects.Album : Objects.TracksContainer {
    Objects.Artist _artist = null;
    public Objects.Artist artist {
        get {
            if (_artist == null) {
                _artist = Byte.database_manager.get_artist_by_album_id (this.ID);
            }
            return _artist;
        }
    }

    public new GLib.List<Track> tracks {
        get {
            if (_tracks == null) {
                _tracks = Byte.database_manager.get_track_collection (this);
            }
            return _tracks;
        }
    }

    public int year { get; set; }

    public Album (Objects.Artist? artist = null) {
        if (artist != null) {
            this.set_artist (artist);
        }
    }

    public void set_artist (Objects.Artist artist) {
        if (artist_track_added_signal_id > 0) {
            disconnect (artist_track_added_signal_id);
            artist_track_added_signal_id = 0;
        }
        this._artist = artist;
    }

    public void add_track_if_not_exists (Objects.Track new_track) {
        if (has_track (new_track)) {
            return;
        }
        new_track.set_album (this);
        Byte.database_manager.insert_track (new_track);
        add_track (new_track);
        load_cover_async (new_track);
    }

    private void load_cover_async (Objects.Track track) {
        if (is_cover_loading || cover != null || this.ID == 0 || this.tracks.length () == 0) {
            return;
        }

        is_cover_loading = true;

        Gst.PbUtils.Discoverer discoverer;
        try {
            discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
        } catch (Error err) {
            warning (err.message);
            return;
        }

        Gst.PbUtils.DiscovererInfo info;
        try {
            info = discoverer.discover_uri (track.uri);
        } catch (Error err) {
            return;
        }

        if (info.get_result () != Gst.PbUtils.DiscovererResult.OK) {
            return;
        }

        Gdk.Pixbuf pixbuf = null;
        var tag_list = info.get_tags ();
        var sample = get_cover_sample (tag_list);

        if (sample == null) {
            tag_list.get_sample_index (Gst.Tags.PREVIEW_IMAGE, 0, out sample);
        }

        if (sample != null) {
            var buffer = sample.get_buffer ();
            if (buffer != null) {
                pixbuf = get_pixbuf_from_buffer (buffer);
                if (pixbuf != null) {
                    discoverer.stop ();
                    save_cover (track, pixbuf, 256);
                }
            }
        }
    }

    private static Gst.Sample? get_cover_sample (Gst.TagList tag_list) {
        Gst.Sample cover_sample = null;
        Gst.Sample sample;
        for (int i = 0; tag_list.get_sample_index (Gst.Tags.IMAGE, i, out sample); i++) {
            var caps = sample.get_caps ();
            unowned Gst.Structure caps_struct = caps.get_structure (0);
            int image_type = Gst.Tag.ImageType.UNDEFINED;
            caps_struct.get_enum ("image-type", typeof (Gst.Tag.ImageType), out image_type);
            if (image_type == Gst.Tag.ImageType.UNDEFINED && cover_sample == null) {
                cover_sample = sample;
            } else if (image_type == Gst.Tag.ImageType.FRONT_COVER) {
                return sample;
            }
        }

        return cover_sample;
    }

    private static Gdk.Pixbuf? get_pixbuf_from_buffer (Gst.Buffer buffer) {
        Gst.MapInfo map_info;

        if (!buffer.map (out map_info, Gst.MapFlags.READ)) {
            warning ("Could not map memory buffer");
            return null;
        }

        Gdk.Pixbuf pix = null;

        try {
            var loader = new Gdk.PixbufLoader ();
            if (loader.write (map_info.data) && loader.close ()) {
                pix = loader.get_pixbuf ();
            }
        } catch (Error err) {
            warning ("Error processing image data: %s", err.message);
        }

        buffer.unmap (map_info);

        return pix;
    }
}
