public class MainWindow : Gtk.Window {
    private uint configure_id;

    private Widgets.HeaderBar headerbar;
    private Widgets.MediaControl media_control;

    private Widgets.Welcome welcome_view;
    private Views.Home home_view;
    private Views.Albums albums_view = null;
    private Views.Tracks tracks_view = null;
    private Views.Artists artists_view = null;
    private Views.Radios radios_view =  null;
    private Views.Playlists playlists_view = null;
    private Views.Favorites favorites_view = null;
    private Views.Playlist playlist_view;
    private Views.Artist artist_view;

    private Views.Album album_view;

    private Widgets.QuickFind quick_find;
    private Widgets.Queue queue;

    private Gtk.Stack main_stack;
    private Gtk.Stack library_stack;

    public MainWindow (Byte application) {
        Object (
            application: application,
            icon_name: "com.github.alainm23.byte",
            title: "Byte"
        );
    }

    construct {
        get_style_context ().add_class ("rounded");

        headerbar = new Widgets.HeaderBar ();

        headerbar.show_quick_find.connect (() => {
            quick_find.reveal = true;
        });

        set_titlebar (headerbar);

        // Media control
        media_control = new Widgets.MediaControl ();

        // Media Stack
        library_stack = new Gtk.Stack ();
        library_stack.expand = true;
        library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        home_view = new Views.Home ();
        
        album_view = new Views.Album ();
        playlist_view = new Views.Playlist ();
        artist_view = new Views.Artist ();

        library_stack.add_named (home_view, "home_view");
        library_stack.add_named (album_view, "album_view");
        library_stack.add_named (playlist_view, "playlist_view");
        library_stack.add_named (artist_view, "artist_view");

        var library_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_view.pack_start (media_control, false, false, 0);
        library_view.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        library_view.pack_start (library_stack, true, true, 0);

        // Welcome
        welcome_view = new Widgets.Welcome ();

        var welcome_scrolled = new Gtk.ScrolledWindow (null, null);
        welcome_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        welcome_scrolled.expand = true;
        welcome_scrolled.add (welcome_view);

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (welcome_scrolled, "welcome_view");
        main_stack.add_named (library_view, "library_view");

        quick_find = new Widgets.QuickFind ();
        queue = new Widgets.Queue ();

        var overlay = new Gtk.Overlay ();
        overlay.add_overlay (quick_find);
        overlay.add_overlay (queue);
        overlay.add (main_stack);

        add (overlay);

        Timeout.add (200, () => {
            if (Byte.database.is_database_empty ()) {
                main_stack.visible_child_name = "welcome_view";
                headerbar.visible_ui = false;
            } else {
                main_stack.visible_child_name = "library_view";
                library_stack.visible_child_name = "home_view";
                headerbar.visible_ui = true;

                if (Byte.settings.get_boolean ("sync-files")) {
                    Byte.scan_service.scan_local_files (Byte.settings.get_string ("library-location"));
                }
            }

            return false;
        });

        welcome_view.selected.connect ((index) => {
            string folder;
            if (index == 0) {
                folder = "file://" + GLib.Environment.get_user_special_dir (GLib.UserDirectory.MUSIC);
            } else {
                folder = Byte.scan_service.choose_folder (this);
            }

            if (folder != null) {
                headerbar.visible_ui = true;

                Byte.settings.set_string ("library-location", folder);
                Byte.scan_service.scan_local_files (folder);

                main_stack.visible_child_name = "library_view";
                library_stack.visible_child_name = "home_view";
            }
        });

        playlist_view.go_back.connect (() => {
            library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            library_stack.visible_child_name = "playlists_view";
        });

        album_view.go_back.connect (() => {
            library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            library_stack.visible_child_name = "albums_view";
        });

        artist_view.go_back.connect (() => {
            library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
            library_stack.visible_child_name = "artists_view";
        });
        
        home_view.go_albums_view.connect (() => {
            go_view ("albums_view");
        });

        home_view.go_tracks_view.connect (() => {
            go_view ("tracks_view");
        });

        home_view.go_artists_view.connect (() => {
            go_view ("artists_view");
        });

        home_view.go_radios_view.connect (() => {
            go_view ("radios_view");
        });

        home_view.go_playlists_view.connect (() => {
            go_view ("playlists_view");
        });

        home_view.go_favorites_view.connect (() => {
            go_view ("favorites_view");
        });

        Byte.database.reset_library.connect (() => {
            main_stack.visible_child_name = "welcome_view";
            headerbar.visible_ui = false;
        });

        delete_event.connect (() => {
            if (Byte.settings.get_boolean ("play-in-background")) {
                if (Byte.player.player_state == Gst.State.PLAYING) {
                    return hide_on_delete ();
                } else {
                    return false;
                }
            } else {
                return false;
            }
        });

        Byte.scan_service.sync_started.connect (() => {
            Granite.Services.Application.set_progress_visible.begin (true, (obj, res) => {
                try {
                    Granite.Services.Application.set_progress_visible.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        Byte.scan_service.sync_finished.connect (() => {
            Granite.Services.Application.set_progress_visible.begin (false, (obj, res) => {
                try {
                    Granite.Services.Application.set_progress_visible.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        Byte.scan_service.sync_progress.connect ((fraction) => {
            Granite.Services.Application.set_progress.begin (fraction, (obj, res) => {
                try {
                    Granite.Services.Application.set_progress.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });
    }

    private void go_view (string view) {
        library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;

        if (view == "tracks_view") {
            if (tracks_view == null) {
                tracks_view = new Views.Tracks ();

                tracks_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                });

                library_stack.add_named (tracks_view, "tracks_view");
            }

            library_stack.visible_child_name = "tracks_view";
        } else if (view == "playlists_view") {
            if (playlists_view == null) {
                playlists_view = new Views.Playlists ();

                playlists_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                });
        
                playlists_view.go_playlist.connect ((playlist) => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
                    library_stack.visible_child_name = "playlist_view";
                    playlist_view.playlist = playlist;
                });

                library_stack.add_named (playlists_view, "playlists_view");
            }

            library_stack.visible_child_name = "playlists_view";
        } else if (view == "albums_view") {
            if (albums_view == null) {
                albums_view = new Views.Albums ();

                albums_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                });
        
                albums_view.go_album.connect ((album) => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
                    library_stack.visible_child_name = "album_view";
                    album_view.album = album;
                });

                library_stack.add_named (albums_view, "albums_view");
            }

            library_stack.visible_child_name = "albums_view";
        } else if (view == "artists_view") {
            if (artists_view == null) {
                artists_view = new Views.Artists ();

                artists_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                });

                artists_view.go_artist.connect ((artist) => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
                    library_stack.visible_child_name = "artist_view";
                    artist_view.artist = artist;
                });

                library_stack.add_named (artists_view, "artists_view");
            }

            library_stack.visible_child_name = "artists_view";
        } else if (view == "radios_view") {
            if (radios_view == null) {
                radios_view = new Views.Radios ();

                radios_view.show_quick_find.connect (() => {
                    quick_find.reveal = !quick_find.reveal_child;
                });

                radios_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                    quick_find.reveal = false;
                });

                library_stack.add_named (radios_view, "radios_view");
            }

            library_stack.visible_child_name = "radios_view";
        } else if (view == "favorites_view") {
            if (favorites_view == null) {
                favorites_view = new Views.Favorites ();

                favorites_view.go_back.connect (() => {
                    library_stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;
                    library_stack.visible_child_name = "home_view";
                });

                library_stack.add_named (favorites_view, "favorites_view");
            }
            
            library_stack.visible_child_name = "favorites_view";
        }
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            Gdk.Rectangle rect;
            get_allocation (out rect);
            Byte.settings.set ("window-size", "(ii)", rect.width, rect.height);

            int root_x, root_y;
            get_position (out root_x, out root_y);
            Byte.settings.set ("window-position", "(ii)", root_x, root_y);

            return false;
        });

        return base.configure_event (event);
    }
}
