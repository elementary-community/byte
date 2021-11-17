public enum ViewType {
    TRACKS,
    ALBUMS,
    ARTISTS,
    PLAYLISTS
}

public class Byte : Gtk.Application {
    public const string ACTION_PREFIX = "app.";
    public const string ACTION_PLAY_PAUSE = "action-play-pause";

    public static Services.Database database_manager;
    public static Services.Library library_manager;
    public static Services.Playback? playback_manager = null;

    public Byte () {
        Object (
            application_id: "com.github.alainm23.byte",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    construct {
        create_dir_with_parents ("/com.github.alainm23.byte");
        create_dir_with_parents ("/com.github.alainm23.byte/covers");
        
        database_manager = new Services.Database ();
        library_manager = new Services.Library ();
    }

    protected override void activate () {
        playback_manager = new Services.Playback ();

        var main_window = new MainWindow (this);
        main_window.set_size_request (425, 640);
        main_window.show_all ();

        database_manager.open_database ();

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/alainm23/byte/stylesheet.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/com/github/alainm23/byte");
    }

    protected override void open (File[] files, string hint) {
        if (playback_manager == null) {
            activate ();
        }

         foreach (unowned var file in files) {
             if (file.query_exists ()) {
                print ("File: %s".printf (file.get_uri ()));
                library_manager.discover_uri (file.get_uri ());
             }
         }
    }

    public void create_dir_with_parents (string dir) {
        string path = Environment.get_user_data_dir () + dir;
        File tmp = File.new_for_path (path);
        if (tmp.query_file_type (0) != FileType.DIRECTORY) {
            GLib.DirUtils.create_with_parents (path, 0775);
        }
    }

    public static int main (string[] args) {
        Gst.init (ref args);
        return new Byte ().run (args);
    }
}