/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Services.Library : GLib.Object {
    private Gst.PbUtils.Discoverer discoverer;
    string unknown = _("Unknown");

    public int discover_counter { get; private set; default = 0; }
    public int discover_counter_max { get; private set; default = 0; }

    public signal void sync_started ();
    public signal void sync_finished ();
    public signal void sync_progress (double fraction);

    construct {
        try {
            discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (5 * Gst.SECOND));
            discoverer.start ();
            discoverer.discovered.connect (discovered);
        } catch (Error err) {
            warning (err.message);
        }
    }

    public void scan_local_files (string uri) {
        new Thread<void*> ("scan_local_files", () => {
            File directory = File.new_for_uri (uri.replace ("#", "%23"));
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
                        // Without usleep it crashes on smb:// protocol and mounted devices
                        //if (!directory.get_uri ().has_prefix ("file://")) {
                            Thread.usleep (1000000);
                        //}
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

    private void found_music_file (string path) {
        print ("Path: %s\n".printf (path));
        discoverer.discover_uri_async (path);
    }

    public static bool is_audio_file (string mime_type) {
        return mime_type.has_prefix ("audio/") && !mime_type.contains ("x-mpegurl") && !mime_type.contains ("x-scpls");
    }
    
    public string? choose_folder (MainWindow window) {
        string? return_value = null;

        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
            _ ("Select a folder."), window, Gtk.FileChooserAction.SELECT_FOLDER,
            _ ("Cancel"), Gtk.ResponseType.CANCEL,
            _ ("Open"), Gtk.ResponseType.ACCEPT);

        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_("Folder"));
        filter.add_mime_type ("inode/directory");

        chooser.add_filter (filter);

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
            return_value = chooser.get_file ().get_uri ();
        }

        chooser.destroy ();
        return return_value;
    }

    private void discovered (Gst.PbUtils.DiscovererInfo info, Error? err) {
        new Thread<void*> (null, () => {
            string uri = info.get_uri ();
            if (info.get_result () != Gst.PbUtils.DiscovererResult.OK) {
                if (err != null) {
                    warning ("DISCOVER ERROR: '%d' %s %s\n(%s)", err.code, err.message, info.get_result ().to_string (), uri);
                }
            } else {
                var tags = info.get_tags ();
                if (tags != null) {
                    uint64 duration = info.get_duration ();
                    string o;
                    GLib.Date? d;
                    Gst.DateTime? dt;
                    uint u;
                    uint64 u64 = 0;

                    // TRACK REGION
                    var track = new Objects.Track ();
                    track.uri = uri;
                    track.duration = duration;
                    if (tags.get_string (Gst.Tags.TITLE, out o)) {
                        track.title = o;
                    }
                    if (track.title.strip () == "") {
                        track.title = Path.get_basename (uri);
                    }
                    if (tags.get_uint (Gst.Tags.TRACK_NUMBER, out u)) {
                        track.track = (int)u;
                    }
                    if (tags.get_uint (Gst.Tags.ALBUM_VOLUME_NUMBER, out u)) {
                        track.disc = (int)u;
                    }
                    if (tags.get_string (Gst.Tags.GENRE, out o)) {
                        track.genre = o;
                    }
                    if (track.duration == 0 && tags.get_uint64 (Gst.Tags.DURATION, out u64)) {
                        track.duration = u64;
                    }

                    // ALBUM REGION
                    var album = new Objects.Album ();
                    if (tags.get_string (Gst.Tags.ALBUM, out o)) {
                        album.title = o;
                    }

                    if (album.title.strip () == "") {
                        var dir = Path.get_dirname (uri);
                        if (dir != null) {
                            album.title = Path.get_basename (dir);
                        } else {
                            album.title = unknown;
                        }
                    }

                    if (tags.get_date_time (Gst.Tags.DATE_TIME, out dt)) {
                        if (dt != null) {
                            album.year = dt.get_year ();
                        } else if (tags.get_date (Gst.Tags.DATE, out d)) {
                            if (d != null) {
                                album.year = dt.get_year ();
                            }
                        }
                    }

                    // ARTIST REGION
                    var artist = new Objects.Artist ();
                    if (tags.get_string (Gst.Tags.ALBUM_ARTIST, out o)) {
                        artist.name = o;
                    } else if (tags.get_string (Gst.Tags.ARTIST, out o)) {
                        artist.name = o;
                    }

                    if (artist.name.strip () == "") {
                        var dir = Path.get_dirname (Path.get_dirname (uri));
                        if (dir != null) {
                            artist.name = Path.get_basename (dir);
                        } else {
                            artist.name = unknown;
                        }
                    }

                    discovered_new_item (artist, album, track);
                }
            }

            info.dispose ();

            return null;
        });
    }

    public void discovered_new_item (Objects.Artist artist, Objects.Album album, Objects.Track track) {
        new Thread<void*> ("discovered_new_local_item", () => {
            
            var db_artist = Byte.database_manager.insert_artist_if_not_exists (artist);
            var db_album = db_artist.add_album_if_not_exists (album);
            db_album.add_track_if_not_exists (track);

            // discover_counter--;
            // if (discover_counter == 0) {
            //     sync_finished ();
            // }

            // double progress = ((double) discover_counter_max - (double) discover_counter) / (double) discover_counter_max;
            // sync_progress (progress);
            // print ("Max: %s\n".printf (discover_counter_max.to_string ()));
            // print ("Counter: %s\n".printf (discover_counter.to_string ()));
            // print ("Progress: %s%\n".printf (progress.to_string ()));

            return null;
        });
    }

    public void discover_uri (string uri) {
        // discoverer.stop ();
        // Gst.PbUtils.DiscovererInfo info = discoverer.discover_uri (uri);
        // new Thread<void*> (null, () => {
        //     if (info.get_result () != Gst.PbUtils.DiscovererResult.OK) {
        //         warning ("DISCOVER ERROR: %s\n(%s)", info.get_result ().to_string (), uri);
        //     } else {
        //         var tags = info.get_tags ();
        //         if (tags != null) {
        //             Objects.Track track;
        //             Objects.Album album;
        //             Objects.Artist artist;

        //             discover_get_objects (uri, info, tags, out artist, out album, out track);

        //             album.set_artist (artist);
        //             track.set_album (album);

        //             Byte.playback_manager.set_track (track);
        //         }
        //     }

        //     info.dispose ();

        //     return null;
        // });
    }

    // public GLib.List<Objects.Artist> get_popular_artists () {
    //     var returned = Byte.database_manager.artists;
    //     return returned;
    // } 
}