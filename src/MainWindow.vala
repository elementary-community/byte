public class MainWindow : Gtk.Window {
    public weak Application app { get; construct; }
    private Widgets.HeaderBar headerbar;
    private Widgets.ActionBar actionbar;

    private Views.Welcome welcome_view;
    private Views.Main main_view;

    private Gtk.Stack main_stack;

    public MainWindow (Application application) {
        Object (
            application: application,
            app: application,
            icon_name: "com.github.alainm23.byte",
            title: _("Byte")
            //height_request: 750,
            //width_request: 575
        );
    }

    construct {
        headerbar = new Widgets.HeaderBar (this);
        headerbar.show_close_button = true;

        set_titlebar (headerbar);

        welcome_view = new Views.Welcome ();
        main_view = new Views.Main ();

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (welcome_view, "welcome_view");
        main_stack.add_named (main_view, "main_view");

        actionbar = new Widgets.ActionBar ();

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (main_stack, true, true, 0);
        main_box.pack_end (actionbar, false, false, 0);

        add (main_box);

        Timeout.add (200, () => {
            if (Application.settings.get_string ("library-location") == "") {
                main_stack.visible_child_name = "welcome_view";
            } else {
                main_stack.visible_child_name = "main_view";
            }
            return false;
        });

        welcome_view.selected.connect ((index) => {
            if (index == 0) {
                string folder = Application.utils.choose_folder (this);
                if (folder != null) {
                    Application.settings.set_string ("library-location", folder);
                    Application.utils.scan_local_files (folder);

                    main_stack.visible_child_name = "main_view";
                }
            }
        });
    }
}
