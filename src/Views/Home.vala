public class Views.Home : Gtk.EventBox {
    public signal void go_albums_view ();
    public signal void go_tracks_view ();
    public signal void go_artists_view ();
    public signal void go_radios_view ();
    public Home () {}

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        get_style_context ().add_class ("w-round");

        // Spinner loading
        var loading_spinner = new Gtk.Spinner ();
        loading_spinner.active = true;
        loading_spinner.start ();

        var loading_label = new Gtk.Label (_("Sync library…"));

        var loading_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        loading_box.halign = Gtk.Align.CENTER;
        loading_box.hexpand = true;
        loading_box.margin = 6;
        loading_box.add (loading_spinner);
        loading_box.add (loading_label);

        var loading_revealer = new Gtk.Revealer ();
        loading_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        loading_revealer.add (loading_box);
        loading_revealer.reveal_child = false;

        var library_label = new Gtk.Label ("<b>%s</b>".printf (_("Library")));
        library_label.get_style_context ().add_class ("font-bold");
        library_label.get_style_context ().add_class ("h3");
        library_label.margin_start = 12;
        library_label.margin_top = 9;
        library_label.halign =Gtk.Align.START;
        library_label.use_markup = true;
        
        var recently_added_label = new Gtk.Label ("<b>%s</b>".printf (_("Recently added")));
        recently_added_label.get_style_context ().add_class ("font-bold");
        recently_added_label.get_style_context ().add_class ("h3");
        recently_added_label.margin_start = 12;
        recently_added_label.halign =Gtk.Align.START;
        recently_added_label.use_markup = true;

        var playlists_button = new Widgets.HomeButton (_("Playlists"), "planner-playlist-symbolic");
        var albums_button = new Widgets.HomeButton (_("Albums"), "planner-album-symbolic");
        var songs_button = new Widgets.HomeButton (_("Songs"), "planner-track-symbolic");
        var artists_button = new Widgets.HomeButton ("Artists", "planner-artist-symbolic");
        var radios_button = new Widgets.HomeButton ("Radios", "planner-radio-symbolic");
        var favorites_button = new Widgets.HomeButton ("Favorites", "planner-favorite-symbolic");

        var items_grid = new Gtk.Grid ();
        items_grid.row_spacing = 12;
        items_grid.column_spacing = 12;
        items_grid.margin = 12;
        items_grid.column_homogeneous = true;
        items_grid.row_homogeneous = true;
        items_grid.attach (songs_button,     0, 0, 1, 1);
        items_grid.attach (albums_button,    1, 0, 1, 1);
        items_grid.attach (playlists_button, 0, 1, 1, 1);
        items_grid.attach (artists_button, 1, 1, 1, 1);
        items_grid.attach (favorites_button,    0, 2, 1, 1);
        items_grid.attach (radios_button,   1, 2, 1, 1);

        var library_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_box.vexpand = true;
        library_box.hexpand = false;
        library_box.pack_start (loading_revealer, false, false, 0);
        library_box.pack_start (library_label, false, false, 0);
        library_box.pack_start (items_grid, false, false, 0);
        library_box.pack_start (recently_added_label, false, false, 0);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled_window.expand = true;
        scrolled_window.add (library_box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (scrolled_window, true, true, 0);

        add (main_box);

        albums_button.clicked.connect (() => {
            go_albums_view ();
        });

        songs_button.clicked.connect (() => {
            go_tracks_view ();
        });

        artists_button.clicked.connect (() => {
            go_artists_view ();
        });

        radios_button.clicked.connect (() => {
            go_radios_view ();
            /*
            var radio = new Objects.Radio ();
            radio.name = "Radio Planeta";
            radio.url = "http://www.181.fm/stream/pls/181-energy93.pls";
            
            Byte.player.set_radio (radio);
            */
        });
    }
}