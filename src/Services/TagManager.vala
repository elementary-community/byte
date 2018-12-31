public class Services.TagManager : GLib.Object {
    private Gst.PbUtils.Discoverer discoverer;

    private string unknown = _("Unknown");
    public int discover_counter { get; private set; default = 0; }

    public TagManager () {}

    construct {
        try {
            discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
            discoverer.start ();
            discoverer.discovered.connect (discovered);
        } catch (Error err) {
            warning (err.message);
        }
    }

    private void discovered (Gst.PbUtils.DiscovererInfo info, Error? err) {
        new Thread<void*> (null, () => {
            string uri = info.get_uri ();

            if (info.get_result () != Gst.PbUtils.DiscovererResult.OK) {
                if (err != null) {
                    warning ("DISCOVER ERROR: '%d' %s %s\n(%s)", err.code, err.message, info.get_result ().to_string (), uri);
                }
            } else {
                var tags = info.get_tags ();

                if (tags != null) {
                    uint64 duration = info.get_duration ();
                    string _title;
                    string _genre;
                    string _album;
                    string _artist;
                    uint64 _duration = 0;

                    // TRACK OBJECT
                    var track = new Objects.Track ();
                    track.duration = duration;
                    track.path = uri;

                    if (tags.get_string (Gst.Tags.TITLE, out _title)) {
                        track.title = _title;
                    }

                    if (track.title.strip () == "") {
                        track.title = Path.get_basename (uri);
                    }

                    if (tags.get_string (Gst.Tags.GENRE, out _genre)) {
                        track.genre = _genre;
                    }

                    if (track.duration == 0 && tags.get_uint64 (Gst.Tags.DURATION, out _duration)) {
                        track.duration = _duration;
                    }

                    if (tags.get_string (Gst.Tags.ALBUM, out _album)) {
                        track.album = _album;
                    }

                    if (tags.get_string (Gst.Tags.ALBUM_ARTIST, out _artist)) {
                        track.artist = _artist;
                    } else if (tags.get_string (Gst.Tags.ARTIST, out _artist)) {
                        track.artist = _artist;
                    }


                    Application.database.add_track (track);
                }
            }

            discover_counter = discover_counter - 1;
            if (discover_counter == 0) {
                //discover_finished ();
            }

            info.dispose ();
            return null;
        });
    }

    public void add_discover_uri (string uri) {
        if (discover_counter == 0) {
            //discover_started ();
        }

        discover_counter = discover_counter + 1;
        discoverer.discover_uri_async (uri);
    }
}
