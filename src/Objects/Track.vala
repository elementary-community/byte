public class Objects.Track : GLib.Object {
    public int id;
    public int album_id;
    public string path;
    public string title;
    public int track;
    public int disc;
    public int is_favorite;
    public uint64 duration;
    public string added_date;
    public string album_title;
    public string artist_name;

    public Track (int id = 0,
                  int album_id = 0,
                  string path = "",
                  string title = "",
                  int track = 0, 
                  int disc = 0,
                  int is_favorite = 0,
                  uint64 duration = 0,
                  string added_date = new GLib.DateTime.now_local ().to_string (),
                  string album_title = "",
                  string artist_name = "") {
        this.id = id;
        this.album_id = album_id;
        this.path = path;
        this.title = title;
        this.track = track;
        this.disc = disc;
        this.is_favorite = is_favorite;
        this.duration = duration;
        this.added_date = added_date;
        this.album_title = album_title;
        this.artist_name = artist_name;
    }
}
