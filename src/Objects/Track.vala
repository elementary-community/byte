public class Objects.Track {
    public int id;
    public string path;
    public string title;
    public string artist;
    public string genre;
    public string album;
    public uint64 duration;

    public Track (int id = 0,
                  string path = "",
                  string title = "",
                  string artist = "",
                  string genre = "",
                  string album = "",
                  uint64 duration = 0) {
        this.id = id;
        this.path = path;
        this.title = title;
        this.artist = artist;
        this.genre = genre;
        this.album = album;
        this.duration = duration;
    }
}
