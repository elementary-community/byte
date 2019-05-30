public class MainWindow : Gtk.Window {
    private Widgets.HeaderBar headerbar;
    private Widgets.MediaControl media_control;

    private Widgets.Welcome welcome_view;
    private Views.Home home_view;
    private Views.Albums albums_view;

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
        set_titlebar (headerbar);

        // Media control
        media_control = new Widgets.MediaControl ();

        // Media Stack
        library_stack = new Gtk.Stack ();
        library_stack.expand = true;
        library_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        home_view = new Views.Home ();
        albums_view = new Views.Albums ();

        library_stack.add_named (home_view, "home_view");
        library_stack.add_named (albums_view, "albums_view");

        var library_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_view.pack_start (media_control, false, false, 0);
        library_view.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        library_view.pack_start (library_stack, true, true, 0);

        // Welcome
        welcome_view = new Widgets.Welcome ();

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (welcome_view, "welcome_view");
        main_stack.add_named (library_view, "library_view");

        add (main_stack);

        Timeout.add (200, () => {
            if (Byte.database.is_database_empty ()) {
                main_stack.visible_child_name = "welcome_view";
                headerbar.visible_ui = false;
            } else {
                main_stack.visible_child_name = "library_view";
                headerbar.visible_ui = true;
            }

            return false;
        });

        welcome_view.selected.connect ((index) => {
            if (index == 0) {
                string folder = Byte.scan_service.choose_folder (this);
                if (folder != null) {
                    Byte.settings.set_string ("library-location", folder);
                    Byte.scan_service.scan_local_files (folder);

                    main_stack.visible_child_name = "library_view";
                    headerbar.visible_ui = true;
                }
            }
        });

        albums_view.go_back.connect (() => {
            library_stack.visible_child_name = "home_view";
        });

        home_view.go_albums_view.connect (() => {
            library_stack.visible_child_name = "albums_view";
        });
    }
 
    public void toggle_playing () {
        headerbar.toggle_playing ();
    }

    public override bool configure_event (Gdk.EventConfigure event) {
        Gtk.Allocation rect;
        get_allocation (out rect);
        Byte.settings.set_value ("window-size",  new int[] { rect.height, rect.width });

        int root_x, root_y;
        get_position (out root_x, out root_y);
        Byte.settings.set_value ("window-position",  new int[] { root_x, root_y });

        return base.configure_event (event);
    }
}
