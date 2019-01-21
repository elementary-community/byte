public class Utils : GLib.Object {
    public Gee.ArrayList<Objects.Track?> playlist;
    public Gee.ArrayList<Objects.Track?> playlist_shuffle;

    public Utils () {    
        playlist = new Gee.ArrayList<Objects.Track?> ();
        playlist_shuffle = new Gee.ArrayList<Objects.Track?> ();
    }

    public void add_track_playlist (Objects.Track? track) {
        playlist.add (track);
    }

    public Objects.Track? get_first_track () {
        return playlist [0];
    }

    public Objects.Track? get_next_track () {
        var current_track = Application.player.current_track;
        var index = playlist.index_of (current_track);

        if (index + 1 >= playlist.size) {
            return playlist [0];
        } else {
            return playlist [index + 1];
        }
    }

    public Objects.Track? get_prev_track () {
        var current_track = Application.player.current_track;
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

    public static bool is_audio_file (string mime_type) {
        return mime_type.has_prefix ("audio/") && !mime_type.contains ("x-mpegurl") && !mime_type.contains ("x-scpls");
    }

    public void scan_local_files (string uri) {
        new Thread<void*> ("scan_local_files", () => {
            File directory = File.new_for_uri (uri.replace ("#", "%23"));
            stdout.printf ("%s\n", directory.get_uri ());
            try {
                var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE + "," + FileAttribute.STANDARD_IS_HIDDEN + "," + FileAttribute.STANDARD_IS_SYMLINK + "," + FileAttribute.STANDARD_SYMLINK_TARGET, GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_is_hidden ()) {
                        continue;
                    }

                    if (file_info.get_is_symlink ()) {
                        string target = file_info.get_symlink_target ();
                        var symlink = File.new_for_path (target);
                        var file_type = symlink.query_file_type (0);
                        if (file_type == FileType.DIRECTORY) {
                            scan_local_files (target);
                        }
                    } else if (file_info.get_file_type () == FileType.DIRECTORY) {
                        // Without usleep it crashes on smb:// protocol
                        if (!directory.get_uri ().has_prefix ("file://")) {
                            Thread.usleep (1000000);
                        }

                        scan_local_files (directory.get_uri () + "/" + file_info.get_name ());
                    } else {
                        string mime_type = file_info.get_content_type ();
                        if (is_audio_file (mime_type)) {
                            found_music_file (directory.get_uri () + "/" + file_info.get_name ().replace ("#", "%23"));
                        }
                    }
                }

                children.close ();
                children.dispose ();
            } catch (Error err) {
                warning ("%s\n%s", err.message, uri);
            }

            directory.dispose ();
            return null;
        });
    }

    public void found_music_file (string path) {
        new Thread<void*> ("found_local_music_file", () => {
            if (Application.database.music_file_exists (path) == false) {
                Application.tg_manager.add_discover_uri (path);
            }

            return null;
        });
    }

    public string? choose_folder (MainWindow window) {
        string? return_value = null;

        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
            _ ("Select a folder."), window, Gtk.FileChooserAction.SELECT_FOLDER,
            _ ("_Cancel"), Gtk.ResponseType.CANCEL,
            _ ("_Open"), Gtk.ResponseType.ACCEPT);

        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_ ("Folder"));
        filter.add_mime_type ("inode/directory");

        chooser.add_filter (filter);

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
            return_value = chooser.get_file ().get_uri ();
        }

        chooser.destroy ();
        return return_value;
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
