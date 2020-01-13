public class MainWindow : Gtk.Window {
    private uint configure_id;

    private Widgets.HeaderBar headerbar;
    private Widgets.MediaControl media_control;

    private Widgets.Welcome welcome_view;
    private Views.Home home_view;

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
        Byte.navCtrl.stack = library_stack;

        home_view = new Views.Home ();
        Byte.navCtrl.add_named (home_view, "home_view");

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

        Byte.utils.quick_find_toggled.connect (() => {
            quick_find.reveal = !quick_find.reveal;
        });
        
        Byte.utils.hide_quick_find.connect (() => {
            quick_find.reveal = false;
        });

        Timeout.add (200, () => {
            if (Byte.database.is_database_empty ()) {
                main_stack.visible_child_name = "welcome_view";
                headerbar.visible_ui = false;
            } else {
                main_stack.visible_child_name = "library_view";

                Byte.navCtrl.go_root ();
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
                Byte.navCtrl.go_root ();
            }
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

    public void open_file (File file) {
        /*
        if (file.get_uri ().has_prefix ("cdda://")) {
            audio_cd_view.open_file (file);
        } else if (!albums_view.open_file (Uri.unescape_string (file.get_uri ()))) {
            library_manager.player.set_file (file);
        }
        */
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
