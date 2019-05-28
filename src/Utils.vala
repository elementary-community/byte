public class Utils : GLib.Object {
    public Gee.ArrayList<Objects.Track?> playlist;
    public Gee.ArrayList<Objects.Track?> playlist_shuffle;

    public string MAIN_FOLDER;
    public string COVER_FOLDER;

    public Utils () {    
        playlist = new Gee.ArrayList<Objects.Track?> ();
        playlist_shuffle = new Gee.ArrayList<Objects.Track?> ();

        MAIN_FOLDER = Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte";
        COVER_FOLDER = GLib.Path.build_filename (MAIN_FOLDER, "covers");
    }

    public void generate_playlist () {
        playlist = Byte.database.get_all_tracks ();
    }

    public void generate_shuffle_list () {
        playlist_shuffle = Byte.database.get_all_tracks ();

        for (int i = playlist_shuffle.size - 1; i > 0; i--) {
            int random_index = GLib.Random.int_range (0, i);

            var tmp_track = playlist_shuffle [random_index];
            playlist_shuffle [random_index] = playlist_shuffle [i];
            playlist_shuffle [i] = tmp_track;
        }
    }

    public Objects.Track? get_next_shuffle_track () {
        var current_track = Byte.player.current_track;
        var index = playlist_shuffle.index_of (current_track);

        if (index + 1 >= playlist_shuffle.size) {
            return playlist_shuffle [0];
        } else {
            return playlist_shuffle [index + 1];
        }
    }

    public Objects.Track? get_prev_shuffle_track () {
        var current_track = Byte.player.current_track;
        var index = playlist_shuffle.index_of (current_track);

        if (index - 1 < 0) {
            return playlist_shuffle [playlist_shuffle.size - 1];
        } else {
            return playlist_shuffle [index - 1];
        }
    }

    public void add_track_playlist (Objects.Track? track) {
        playlist.add (track);
    }

    public Objects.Track? get_first_track () {
        return playlist [0];
    }

    public Objects.Track? get_next_track () {
        var repeat_mode = Byte.settings.get_enum ("repeat-mode");

        var current_track = Byte.player.current_track;
        var index = playlist.index_of (current_track);

        if (index + 1 >= playlist.size) {
            if (repeat_mode == 0) {
                return null;
            } else {
                return playlist [0];
            }
        } else {
            return playlist [index + 1];
        }
    }

    public Objects.Track? get_prev_track () {
        var current_track = Byte.player.current_track;
        var index = playlist.index_of (current_track);

        if (index - 1 < 0) {
            return playlist [playlist.size - 1];
        } else {
            return playlist [index - 1];
        }
    }

    private void generate_playlist_shuffle () {

    }

    public void create_dir_with_parents (string dir) {
        string path = Environment.get_home_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }
    
    public string get_formated_duration (uint64 duration) {
        uint seconds = (uint)(duration / 1000000000);
        if (seconds < 3600) {
            uint minutes = seconds / 60;
            seconds -= minutes * 60;
            return "%u:%02u".printf (minutes, seconds);
        }

        uint hours = seconds / 3600;
        seconds -= hours * 3600;
        uint minutes = seconds / 60;
        seconds -= minutes * 60;
        return "%u:%02u:%02u".printf (hours, minutes, seconds);
    }
}
