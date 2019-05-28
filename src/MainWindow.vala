public class MainWindow : Gtk.Window {
    private Widgets.HeaderBar headerbar;

    private Views.Welcome welcome_view;
    private Views.Main main_view;

    private Gtk.Stack main_stack;
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

        welcome_view = new Views.Welcome ();
        main_view = new Views.Main ();

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (welcome_view, "welcome_view");
        main_stack.add_named (main_view, "main_view");
        
        add (main_stack);

        Timeout.add (200, () => {
            if (Byte.database.is_database_empty ()) {
                main_stack.visible_child_name = "welcome_view";
                headerbar.visible_ui = false;
            } else {
                main_stack.visible_child_name = "main_view";
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

                    main_stack.visible_child_name = "main_view";
                    headerbar.visible_ui = true;
                }
            }
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
