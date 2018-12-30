public class Application : Gtk.Application {
    public MainWindow main_window;

    public static GLib.Settings settings;
    public static Services.StreamPlayer stream_player;
    public static Services.Signals signals;
    public static Utils utils;

    public string[] argsv;

    public Application (string[] args) {
        Object (
            application_id: "com.github.alainm23.byte",
            flags: ApplicationFlags.HANDLES_OPEN
        );

        settings = new Settings ("com.github.alainm23.byte");
        stream_player = new Services.StreamPlayer (args, "MAIN");
        signals = new Services.Signals ();
        utils = new Utils ();
    }

    protected override void activate () {
        if (get_windows ().length () > 0) {
            get_windows ().data.present ();
            return;
        }

        main_window = new MainWindow (this);
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
        Application app = new Application (args);
        return app.run (args);
    }
}
