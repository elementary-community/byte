public class Objects.Track : GLib.Object {
    public int _id;
    public int id;
    public int album_id;
    public string path;
    public string title;
    public int track;
    public int disc;
    public int play_count;
    public int is_favorite;
    public uint64 duration;
    public string date_added;
    public string album_title;
    public string artist_name;

    public Track (int _id = 0,
                  int id = 0,
                  int album_id = 0,
                  string path = "",
                  string title = "",
                  int track = 0, 
                  int disc = 0,
                  int play_count = 0,
                  int is_favorite = 0,
                  uint64 duration = 0,
                  string date_added = new GLib.DateTime.now_local ().to_string (),
                  string album_title = "",
                  string artist_name = "") {
        this._id = _id;
        this.id = id;
        this.album_id = album_id;
        this.path = path;
        this.title = title;
        this.track = track;
        this.disc = disc;
        this.play_count = play_count;
        this.is_favorite = is_favorite;
        this.duration = duration;
        this.date_added = date_added;
        this.album_title = album_title;
        this.artist_name = artist_name;
    }
}
