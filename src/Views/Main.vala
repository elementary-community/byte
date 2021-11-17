public class Views.Main : Gtk.EventBox {
    private Gtk.FlowBox artist_flowbox;
    private Gtk.FlowBox track_flowbox;

    public signal void navigate (ViewType view_type);

    construct {
        var tracks_button = new Widgets.SecionHeaderAction (_("Songs"), ViewType.TRACKS);
        var albums_button = new Widgets.SecionHeaderAction (_("Albums"), ViewType.ALBUMS);
        var playlist_button = new Widgets.SecionHeaderAction (_("Playlist"), ViewType.PLAYLISTS);
        var artist_button = new Widgets.SecionHeaderAction (_("Artist"), ViewType.ARTISTS);

        var sections_flowbox = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.VERTICAL,
            min_children_per_line = 2,
            max_children_per_line = 2,
            valign = Gtk.Align.CENTER,
            margin = 12,
            margin_start = 6,
            margin_top = 6,
            margin_bottom = 6
        };

        sections_flowbox.add (tracks_button);
        sections_flowbox.add (albums_button);
        sections_flowbox.add (playlist_button);
        sections_flowbox.add (artist_button);

        var artist_header = new Widgets.SectionHeader (_("Popular artist")) {
            margin_top = 12,
            margin_start = 12,
            margin_end = 12
        };
        
        artist_flowbox = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.VERTICAL,
            max_children_per_line = 1,
            valign = Gtk.Align.CENTER,
            margin = 12,
            margin_start = 6,
            margin_top = 6,
            margin_bottom = 6
        };

        var artist_scrolled = new Gtk.ScrolledWindow (null, null) {
            vscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            valign = Gtk.Align.START,
            height_request = 76,
            margin_top = 6
        };

        artist_scrolled.add (artist_flowbox);

        var track_header = new Widgets.SectionHeader (_("Recently added")) {
            margin_top = 6,
            margin_start = 12,
            margin_end = 12
        };

        track_flowbox = new Gtk.FlowBox () {
            orientation = Gtk.Orientation.VERTICAL,
            min_children_per_line = 3,
            max_children_per_line = 3,
            valign = Gtk.Align.CENTER,
            margin = 12,
            margin_start = 6,
            margin_top = 0,
            margin_bottom = 6
        };

        var track_scrolled = new Gtk.ScrolledWindow (null, null) {
            vscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            valign = Gtk.Align.START,
            height_request = 76,
            margin_top = 6
        };

        // track_scrolled.add (track_flowbox);

        var album_header = new Widgets.SectionHeader (_("Playlists")) {
            margin_top = 6,
            margin_start = 12,
            margin_end = 12
        };

        var content = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        content.add (sections_flowbox);
        content.add (artist_header);
        content.add (artist_scrolled);
        content.add (track_header);
        content.add (track_flowbox);
        content.add (album_header);

        var main_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        main_grid.add (content);
        add (main_grid);

        track_flowbox.child_activated.connect ((child) => {
            var track = ((Widgets.TrackChild) child).track;
            Byte.playback_manager.set_track (track);
        });

        sections_flowbox.child_activated.connect ((child) => {
            navigate (((Widgets.SecionHeaderAction) child).view);
        });
    }

    public void get_popular_artists () {
        foreach (var artist in Byte.database_manager.artists) {
            var child = new Widgets.ArtistChild (artist);
            artist_flowbox.add (child);
        }

        artist_flowbox.show_all ();
    }

    public void get_last_track () {
        foreach (var track in Byte.database_manager.get_last_added_track_collection ()) {
            var child = new Widgets.TrackChild (track);
            track_flowbox.add (child);
        }

        track_flowbox.show_all ();
    }
}