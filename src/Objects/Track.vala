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

    public string path_cover;
    public string cover {
        get {
            path_cover = GLib.Path.build_filename (Application.utils.COVER_FOLDER, ("%i.jpg").printf (id));
            var tmp = File.new_for_path (path_cover);

            if (tmp.query_exists ()) {
                return path_cover;
            } else {
                return "/usr/share/com.github.alainm23.byte/default-cover.svg";
            }
        }
    }

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
