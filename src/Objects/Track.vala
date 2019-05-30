public class Objects.Track {
    public int id;
    public int album_id;
    public string path;
    public string title;
    public int track;
    public int disc;
    public uint64 duration;

    public string album_title;
    public string artist_name;

    public Track (int id = 0,
                  int album_id = 0,
                  string path = "",
                  string title = "",
                  int track = 0,
                  int disc = 0,
                  uint64 duration = 0,
                  string album_title = "",
                  string artist_name = "") {
        this.id = id;
        this.album_id = album_id;
        this.path = path;
        this.track = track;
        this.disc = disc;
        this.duration = duration;

        this.album_title = album_title;
        this.artist_name = artist_name;
    }
}
