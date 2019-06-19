public class Utils : GLib.Object {
    public Gee.ArrayList<Objects.Track?> queue_playlist { set; get; }
    public Gee.ArrayList<Objects.Track?> queue_original_playlist { set; get; }

    public signal void play_items (Gee.ArrayList<Objects.Track?> items, Objects.Track? track);
    public signal void update_next_track ();

    public string MAIN_FOLDER;
    public string COVER_FOLDER;
    public Utils () {
        MAIN_FOLDER = Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte";
        COVER_FOLDER = GLib.Path.build_filename (MAIN_FOLDER, "covers");
    }
    
    public void set_items (Gee.ArrayList<Objects.Track?> all_items, bool shuffle_mode, Objects.Track? track) {
        queue_playlist = all_items;
        queue_original_playlist = all_items;

        if (shuffle_mode) {
            queue_playlist = generate_shuffle (queue_playlist);

            if (track != null) {
                int index = get_track_index_by_id (track.id, queue_playlist);
                queue_playlist.remove_at (index);
                queue_playlist.insert (0, track);
            }

            Byte.settings.set_boolean ("shuffle-mode", true);
        } else {
            Byte.settings.set_boolean ("shuffle-mode", false);
        }
        
        play_items (queue_playlist, track);
    }

    public int get_track_index_by_id (int id, Gee.ArrayList<Objects.Track?> queue_playlist) {
        int index = 0;
        foreach (var item in queue_playlist) {
            if (item.id == id) {
                return index;
            }

            index++;
        }

        return index;
    }

    public Gee.ArrayList<Objects.Track?> generate_shuffle (Gee.ArrayList<Objects.Track?> items) {
        for (int i = items.size - 1; i > 0; i--) {
            int random_index = GLib.Random.int_range (0, i);

            var tmp_track = items [random_index];
            items [random_index] = items [i];
            items [i] = tmp_track;
        }

        return items;
    }

    public Objects.Track get_next_track (Objects.Track current_track) {
        int index = get_track_index_by_id (current_track.id, queue_playlist) + 1;
        
        if (index >= queue_playlist.size) {
            var repeat_mode = Byte.settings.get_enum ("repeat-mode");

            if (repeat_mode == 0) {
                return null;
            } else if (repeat_mode == 1) {
                index = 0;
            }
        }

        return queue_playlist [index];
    }

    public Objects.Track get_prev_track (Objects.Track current_track) {
        int index = get_track_index_by_id (current_track.id, queue_playlist) - 1;

        if (index < 0) {
            index = 0;
        }

        return queue_playlist [index];
    }
    
    public void remove_track (int id) {
        var index = get_track_index_by_id (id, queue_playlist);
        queue_playlist.remove_at (index);

        update_next_track ();
    }

    public void download_image (string type, int id, string url) {
        // Create file
        var image_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("%s-%i.jpg").printf (type, id));

        var file_path = File.new_for_path (image_path);
        var file_from_uri = File.new_for_uri (url);
        
        MainLoop loop = new MainLoop ();

        file_from_uri.copy_async.begin (file_path, 0, Priority.DEFAULT, null, (current_num_bytes, total_num_bytes) => {
            // Report copy-status:
            print ("%" + int64.FORMAT + " bytes of %" + int64.FORMAT + " bytes copied.\n", current_num_bytes, total_num_bytes);
        }, (obj, res) => {
            try {
                if (file_from_uri.copy_async.end (res)) {
                    print ("Image Downloaded\n");
                }
            } catch (Error e) {
                download_image (type, id, url);
                print ("Error: %s\n", e.message);
            }

            loop.quit ();
        });

        loop.run ();
    }

    public void create_dir_with_parents (string dir) {
        string path = Environment.get_home_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }
    
    public string get_formated_duration (uint64 duration) {
        uint seconds = (uint) (duration / 1000000000);
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

    public string get_relative_duration (uint64 duration) {
        uint temp_sec = (uint) (duration / 1000000000);
        uint sec = (uint) temp_sec % 60;
        uint min = (uint) ((temp_sec / 60) % 60);
        uint hour = (uint) ((temp_sec / (60 * 60)) % 24);
        uint day = (uint) ((temp_sec / (24 * 60 * 60)) % 24);

        if (day > 0) {
            return "%ud %uh %um %us".printf (day, hour, min, sec);
        } else {
            if (hour > 0) {
                return "%uh %um %us".printf (hour, min, sec);
            } else {
                if (min > 0) {
                    return "%um %us".printf (min, sec);
                } else {
                    if (sec > 0) {
                        return "%us".printf (sec);
                    } else {
                        return "";
                    }
                }
            }
        }
    }

    public string get_cover_file (int album_id) {
        var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id));
        if (File.new_for_path (cover_path).query_exists ()) {
            return "file://" + cover_path;
        }

        return "file:///usr/share/com.github.alainm23.byte/track-default-cover.svg";
    }

    public string get_cover_radio_file (int radio_id) {
        var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("radio-%i.jpg").printf (radio_id));
        if (File.new_for_path (cover_path).query_exists ()) {
            return "file://" + cover_path;
        }

        return "file:///usr/share/com.github.alainm23.byte/radio-default-cover.svg";
    }
}
