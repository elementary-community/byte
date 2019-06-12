public class Services.Lastfm : GLib.Object {
    private Soup.Session session;

    private const string API_KEY = "a33950e8cc5e7130f42697fa957ec42a";
    private const string ROOT_URL = "http://ws.audioscrobbler.com/2.0/";

    public signal void radio_cover_track_found (string url);

    public Lastfm () {
        session = new Soup.Session ();

        Byte.player.current_radio_title_changed.connect ((title) => {
            get_current_radio_cover (title);
        });
    }

    public void get_current_radio_cover (string? title) {
        if (title != null) {
            var media = title.split (" - ");
        
            string artist = "";
            string track = "";
            
            if (media [0] != null && media [1] != null) {
                artist = media [0];
                track = media [1];
                
                string url = ROOT_URL;
                url = url + "?method=track.getInfo";
                url = url + "&api_key=" + API_KEY;
                url = url + "&artist=" + artist;
                url = url + "&track=" + track;
                url = url + "&format=json";

                var message = new Soup.Message ("GET", url);

                session.queue_message (message, (sess, mess) => {
                    if (mess.status_code == 200) {
                        var parser = new Json.Parser ();

                        try {
                            parser.load_from_data ((string) mess.response_body.flatten ().data, -1);

                            var node = parser.get_root ().get_object ();

                            var track_object = node.get_object_member ("track");
                            var album_object = track_object.get_object_member ("album");

                            var image = album_object.get_array_member ("image");

                            foreach (unowned Json.Node item in image.get_elements ()) {
                                var object = item.get_object();

                                if (object.get_string_member ("size") == "large") {
                                    if (object.get_string_member ("#text") != null || object.get_string_member ("#text") != "") {
                                        radio_cover_track_found (object.get_string_member ("#text"));
                                    }
                                }
                            }
                        } catch (Error e) {
                          
                        }
                    } else {

                    }
                });
            }
        }
    }
}