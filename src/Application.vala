public class Application : Gtk.Application {
    public MainWindow main_window;

    public static Services.Database database;
    public static GLib.Settings settings;
    public static Services.Player player;
    public static Services.TagManager tg_manager;
    public static Services.CoverImport cover_import;
    public static Utils utils;

    public string[] argsv;

    public Application (string[] args) {
        Object (
            application_id: "com.github.alainm23.byte",
            flags: ApplicationFlags.HANDLES_OPEN
        );
        // Dir to Database
        utils = new Utils ();
        utils.create_dir_with_parents ("/.cache/com.github.alainm23.byte");
        utils.create_dir_with_parents ("/.cache/com.github.alainm23.byte/covers");

        settings = new Settings ("com.github.alainm23.byte");
        player = new Services.Player ();
        database = new Services.Database ();
        tg_manager = new Services.TagManager ();
        cover_import = new Services.CoverImport ();
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        var window_size = settings.get_value ("window-size");
        var rect = Gtk.Allocation ();
        rect.height = (int32) window_size.get_child_value (0);
        rect.width =  (int32) window_size.get_child_value (1);

        var window_position = settings.get_value ("window-position");
        var window_x = (int32) window_position.get_child_value (0);
        var window_y = (int32) window_position.get_child_value (1);

        main_window = new MainWindow (this);
        if (window_x != -1 ||  window_y != -1) {
            main_window.move (window_x, window_y);
        }

        main_window.set_allocation (rect);
        main_window.show_all ();

        // Actions
        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (() => {
            if (main_window != null) {
                main_window.destroy ();
            }
        });

        // Stylesheet
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/alainm23/byte/stylesheet.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Default Icon Theme
        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/alainm23/byte");
    }
    public static int main (string[] args) {
        Gst.init (ref args);
        Application app = new Application (args);
        return app.run (args);
    }
}
