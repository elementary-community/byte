public class Views.Playlist : Gtk.EventBox {
    private Gtk.Label title_label;
    private Gtk.Label time_label;
    private Gtk.Label update_relative_label;
        
    private Gtk.ListBox listbox;

    private Gtk.Button shuffle_button;

    private string cover_path;
    private Widgets.Cover image_cover;
    
    public signal void go_back (string page);
    public string back_page { set; get; }

    private Gee.ArrayList<Objects.Track?> all_tracks;

    public Objects.Playlist? _playlist;
    public Objects.Playlist playlist {
        set {
            _playlist = value;

            print ("Title: %s\n".printf (_playlist.title));

            title_label.label = _playlist.title;
            time_label.label = "25 songs - 3h, 2 min";
            update_relative_label.label = Byte.utils.get_relative_datetime (_playlist.date_updated);

            try {
                cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("playlist-%i.jpg").printf (_playlist.id));
                var pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, 128, 128);
                image_cover.pixbuf = pixbuf;
            } catch (Error e) {
                var pixbuf = new Gdk.Pixbuf.from_file_at_size ("/usr/share/com.github.alainm23.byte/album-default-cover.svg", 128, 128);
                image_cover.pixbuf = pixbuf;
            }

            /*
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            if (Byte.scan_service.is_sync == false) {
                all_tracks = new Gee.ArrayList<Objects.Track?> ();
                all_tracks = Byte.database.get_all_tracks_by_album (_album.id);
        
                foreach (var item in all_tracks) {
                    var row = new Widgets.TrackAlbumRow (item);
                    listbox.add (row);
                }
        
                listbox.show_all ();
            }
            */
        }
        get {
            return _playlist;
        }
    }

    public Playlist () {}

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");

        var back_button = new Gtk.Button.from_icon_name ("planner-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("label-color-primary");

        var center_label = new Gtk.Label ("<b>%s</b>".printf (_("Playlist")));
        center_label.use_markup = true;
        center_label.valign = Gtk.Align.CENTER;
        center_label.get_style_context ().add_class ("h3");
        center_label.get_style_context ().add_class ("label-color-primary");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_label);

        //cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Widgets.Cover.with_default_icon (64, "playlist");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;
 
        title_label = new Gtk.Label (null);
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.CHAR; 
        title_label.justify = Gtk.Justification.FILL;
        title_label.get_style_context ().add_class ("font-bold");
        title_label.get_style_context ().add_class ("h2");
        title_label.halign = Gtk.Align.START;
        
        time_label = new Gtk.Label (null);
        time_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        time_label.wrap = true;
        time_label.justify = Gtk.Justification.FILL;
        time_label.wrap_mode = Pango.WrapMode.CHAR;
        time_label.halign = Gtk.Align.START;

        var update_label = new Gtk.Label (_("Updated"));
        update_label.margin_top = 6;
        update_label.halign = Gtk.Align.START;
        update_label.ellipsize = Pango.EllipsizeMode.END;
        update_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        update_relative_label = new Gtk.Label (null);
        update_relative_label.halign = Gtk.Align.START;
        update_relative_label.get_style_context ().add_class ("font-bold");
        update_relative_label.ellipsize = Pango.EllipsizeMode.END;

        var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
        play_button.always_show_image = true;
        play_button.label = _("Play");
        play_button.hexpand = true;
        play_button.get_style_context ().add_class ("home-button");
        play_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.MENU);
        shuffle_button.always_show_image = true;
        shuffle_button.label = _("Shuffle");
        shuffle_button.hexpand = true;
        shuffle_button.get_style_context ().add_class ("home-button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var action_grid = new Gtk.Grid ();
        action_grid.margin = 6;
        action_grid.margin_start = 12;
        action_grid.margin_end = 12;
        action_grid.column_spacing = 12;
        action_grid.add (play_button);
        action_grid.add (shuffle_button);

        var detail_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        detail_box.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        detail_box.pack_start (title_label, false, false, 3);
        detail_box.pack_start (time_label, false, false, 0);
        detail_box.pack_start (update_label, false, false, 0);
        detail_box.pack_start (update_relative_label, false, false, 0);

        var album_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        album_box.hexpand = true;
        album_box.margin = 12;
        album_box.margin_bottom = 6;
        album_box.margin_top = 0;
        album_box.pack_start (image_cover, false, false, 0);
        album_box.pack_start (detail_box, false, false, 0);

        listbox = new Gtk.ListBox (); 
        listbox.expand = true; 
        listbox.margin_start = 9;
        listbox.margin_end = 9;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 14;
        separator.margin_end = 9;

        var scrolled_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        scrolled_box.expand = true;
        scrolled_box.pack_start (album_box, false, false, 0);
        scrolled_box.pack_start (separator, false, false, 0);
        scrolled_box.pack_start (action_grid, false, false, 0);
        scrolled_box.pack_start (listbox, true, true, 0);
        
        var main_scrolled = new Gtk.ScrolledWindow (null, null);
        main_scrolled.margin_bottom = 48;
        main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_scrolled.expand = true;
        main_scrolled.add (scrolled_box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (main_scrolled, true, true, 0);

        add (main_box);

        back_button.clicked.connect (() => {
            go_back (back_page);
        });

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackAlbumRow;
            
            Byte.utils.set_items (
                all_tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });

        play_button.clicked.connect (() => {
            Byte.utils.set_items (
                all_tracks,
                false,
                null
            );
        });

        shuffle_button.clicked.connect (() => {
            Byte.utils.set_items (
                all_tracks,
                true,
                null
            );
        });

        /*
        Byte.database.adden_new_track.connect ((track) => {
            if (_album != null && track.album_id == _album.id) {
                var row = new Widgets.TrackAlbumRow (track);
                listbox.add (row);
                listbox.show_all ();
            }
        });

        Byte.database.updated_album_cover.connect ((album_id) => {
            if (_album != null && album_id == _album.id) {
                try {
                    image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (
                        GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id)), 
                        128, 
                        128);
                } catch (Error e) {
                    stderr.printf ("Error setting default avatar icon: %s ", e.message);
                }
            }
        });
        */
    }
}