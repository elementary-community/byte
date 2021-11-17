public class MainWindow : Hdy.ApplicationWindow {
    public Widgets.HeaderBar headerbar;
    public Views.Welcome welcome_view;
    public Views.Main main_view;
    public Views.Tracks tracks_view;

    public Gtk.Stack main_stack;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            height_request: 640,
            resizable: true,
            title: _("Byte"),
            width_request: 300
        );
    }

    construct {
        Hdy.init ();

        headerbar = new Widgets.HeaderBar () {
            hexpand = true,
            show_close_button = true
        };

        welcome_view = new Views.Welcome ();
        main_view = new Views.Main ();
        tracks_view = new Views.Tracks ();

        main_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE
        };

        main_stack.add_named (welcome_view, "welcome");
        main_stack.add_named (main_view, "main");
        main_stack.add_named (tracks_view, "tracks");

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        main_grid.add (headerbar);
        main_grid.add (main_stack);

        var playback_widget = new Widgets.Playback ();

        var main_overlay = new Gtk.Overlay ();
        main_overlay.add_overlay (playback_widget);
        main_overlay.add (main_grid);

        add (main_overlay);

        welcome_view.selected.connect ((index) => {
            string folder;
            if (index == 0) {
                folder = "file://" + GLib.Environment.get_user_special_dir (GLib.UserDirectory.MUSIC);
            } else {
                folder = Byte.library_manager.choose_folder (this);
            }
            
            if (folder != null) {
                Byte.library_manager.scan_local_files (folder);
            }
        });

        Byte.database_manager.opened.connect (() => {
            Timeout.add (main_stack.transition_duration, () => {
                if (Byte.database_manager.is_database_empty ()) {
                    main_stack.visible_child_name = "welcome";
                } else {
                    main_stack.visible_child_name = "main";
                    main_view.get_popular_artists ();
                    main_view.get_last_track ();
                }

                return GLib.Source.REMOVE;
            });
        });

        main_view.navigate.connect ((view_type) => {
            if (view_type == ViewType.TRACKS) {
                main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
                main_stack.visible_child_name = "tracks";
            }
        });
    }
}