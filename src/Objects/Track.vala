public class Objects.Track {
    public int id;
    public int year;
    public string path;
    public string title;
    public string artist;
    public string genre;
    public string lyrics;
    public uint64 duration;
    public string album;

    public Track (int id = 0,
                  string path = "",
                  string title = "",
                  string artist = "",
                  string genre = "",
                  int year = 0,
                  string lyrics = "",
                  string album = "",
                  uint64 duration = 0) {
        this.id = id;
        this.path = path;
        this.title = title;
        this.artist = artist;
        this.genre = genre;
        this.year = year;
        this.lyrics = lyrics;
        this.album = album;
        this.duration = duration;
    }
}
