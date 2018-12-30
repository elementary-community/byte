public class Utils : GLib.Object {
    public void create_dir_with_parents (string dir) {
        string path = Environment.get_home_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }

    private string get_ns_to_min_string (ulong nanoseconds) {
        // Given nanoseconds, transform to minutes and seconds and returns in string with format %M:%S
        int total_seconds = (int) (nanoseconds / 1000000000);
        int minutes = total_seconds / 60;
        int seconds = total_seconds % 60;
        string smin = minutes < 10 ? "0"+minutes.to_string () : minutes.to_string ();
        string ssec = seconds < 10 ? "0"+seconds.to_string () : seconds.to_string ();

        return smin + ":" + ssec;
    }

    public StreamTimeInfo get_position_str () {
        // Returns a struct with position of current file in nanoseconds and string format %M:%S
        ulong pos = Application.stream_player.get_position ();
        return { pos, get_ns_to_min_string (pos) };
    }

    public StreamTimeInfo get_duration_str () {
        // Returns a struct with duration of current file in nanoseconds and string format %M:%S
        ulong dur = Application.stream_player.get_duration();
        return { dur, get_ns_to_min_string (dur) };
    }
}

public struct StreamMetadata {
    public string title;
    public string album;
    public string artist;
}

public struct StreamTimeInfo {
    public ulong nanoseconds;
    public string minutes;
}
