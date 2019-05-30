public class Services.Scan : GLib.Object {
    public signal void sync_started ();
    public signal void sync_finished ();

    uint finish_timer = 0;
    construct {
        Byte.tg_manager.discovered_new_item.connect (discovered_new_local_item);
        Byte.tg_manager.discover_finished.connect (() => {
            sync_finished ();
        });
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

    public void found_music_file (string uri) { 
        cancel_finish_timeout ();
        new Thread<void*> ("found_local_music_file", () => {
            if (Byte.database.music_file_exists (uri) == false) {
                if (Byte.tg_manager.discover_counter == 0) {
                    sync_started ();   
                }

                Byte.tg_manager.add_discover_uri (uri);
            } else if (Byte.tg_manager.discover_counter == 0) {
                finish_timeout ();   
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

    public void discovered_new_local_item (Objects.Artist artist, Objects.Album album, Objects.Track track) {
        new Thread<void*> ("discovered_new_local_item", () => {
            album.artist_id = Byte.database.insert_artist_if_not_exists (artist);
            album.artist_name = artist.name;

            track.album_id = Byte.database.insert_album_if_not_exists (album);
            track.artist_name = artist.name;
            track.album_title = album.title;

            Byte.database.insert_track (track);
            return null;
        });
    }

    public static bool is_audio_file (string mime_type) {
        return mime_type.has_prefix ("audio/") && !mime_type.contains ("x-mpegurl") && !mime_type.contains ("x-scpls");
    }

    private void cancel_finish_timeout () {
        lock (finish_timer) {
            if (finish_timer != 0) {
                Source.remove (finish_timer);
                finish_timer = 0;
            }
        }
    }

    private void finish_timeout () {
        lock (finish_timer) {
            cancel_finish_timeout ();

            finish_timer = Timeout.add (1000, () => {
                sync_finished ();
                cancel_finish_timeout ();
                return false;
            });
        }
    }
}