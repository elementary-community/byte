public class Services.TagManager : GLib.Object {
    private Gst.PbUtils.Discoverer discoverer;

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
                    uint64 _duration = info.get_duration ();
                    string _title;
                    string _genre;
                    string _album;
                    string _artist;
                    string _lyrics;
                    Gst.DateTime? _datetime;
                    Date? _date;

                    // TRACK OBJECT
                    var track = new Objects.Track ();
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

                    if (_duration == 0) {
                        if (!tags.get_uint64 (Gst.Tags.DURATION, out _duration)) {
                            _duration = 0;
                        }
                    }

                    if (tags.get_string (Gst.Tags.ALBUM, out _album)) {
                        track.album = _album;
                    }

                    if (tags.get_string (Gst.Tags.ALBUM_ARTIST, out _artist)) {
                        track.artist = _artist;
                    } else if (tags.get_string (Gst.Tags.ARTIST, out _artist)) {
                        track.artist = _artist;
                    }

                    if (tags.get_string (Gst.Tags.LYRICS, out _lyrics)) {
                        track.lyrics = _lyrics;
                    }

                    if (tags.get_date_time (Gst.Tags.DATE_TIME, out _datetime)) {
                        if (_datetime != null) {
                            track.year = _datetime.get_year ();
                        } else {
                            if (tags.get_date (Gst.Tags.DATE, out _date)) {
                                // Don't let the assumption that @date is non-null deceive you.
                                // This is sometimes null even though get_date() returned true!
                                if (_date != null) {
                                    track.year = _date.get_year ();
                                }
                            }
                        }
                    }

                    track.duration = _duration;

                    Application.database.add_track (track);
                }
            }

            info.dispose ();
            return null;
        });
    }

    public void add_discover_uri (string uri) {
        discoverer.discover_uri_async (uri);
    }
}
