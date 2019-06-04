public class Views.Album : Gtk.EventBox {
    public Objects.Album album { get; construct; }

    private Gtk.Label title_label;
    private Gtk.Label artist_label;
    private Gtk.Label genre_label;
    private Gtk.Label year_label;
    private Gtk.Button shuffle_button;

    private string cover_path;
    private Widgets.Cover image_cover;
    
    public signal void go_back ();

    private bool is_initialized = false;
    
    public Album (Objects.Album album) {
        Object (
            album: album
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");

        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Albums")));
        title_label.use_markup = true;
        title_label.valign = Gtk.Align.CENTER;
        title_label.get_style_context ().add_class ("h3");

        var search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;
        search_entry.width_request = 250;
        search_entry.get_style_context ().add_class ("search-entry");
        search_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_entry.placeholder_text = _("Your library");

        var center_stack = new Gtk.Stack ();
        center_stack.hexpand = true;
        center_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        center_stack.add_named (title_label, "title_label");
        center_stack.add_named (search_entry, "search_entry");
        
        center_stack.visible_child_name = "title_label";

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.margin = 6;
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_stack);
        header_box.pack_end (search_button, false, false, 0);

        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album.id));
        image_cover = new Widgets.Cover.from_file (cover_path, 128, "album");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        title_label = new Gtk.Label (album.title);
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.CHAR; 
        title_label.justify = Gtk.Justification.FILL;
        title_label.get_style_context ().add_class ("font-bold");
        title_label.halign = Gtk.Align.START;
        
        artist_label = new Gtk.Label (album.artist_name);
        artist_label.get_style_context ().add_class ("font-album-artist");
        artist_label.wrap = true;
        artist_label.justify = Gtk.Justification.FILL;
        artist_label.wrap_mode = Pango.WrapMode.CHAR;
        artist_label.halign = Gtk.Align.START;

        genre_label = new Gtk.Label (album.genre);
        genre_label.halign = Gtk.Align.START;
        genre_label.ellipsize = Pango.EllipsizeMode.END;
        genre_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        year_label = new Gtk.Label ("%i".printf (album.year));
        year_label.halign = Gtk.Align.START;
        year_label.ellipsize = Pango.EllipsizeMode.END;
        year_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.BUTTON);
        shuffle_button.label = (_("Shuffle"));
        shuffle_button.margin_bottom = 3;
        shuffle_button.valign = Gtk.Align.CENTER;
        shuffle_button.always_show_image = true;
        shuffle_button.width_request = 150;
        shuffle_button.get_style_context ().add_class ("shuffle-button");

        var detail_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        detail_box.get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        detail_box.pack_start (title_label, false, false, 3);
        detail_box.pack_start (artist_label, false, false, 0);
        detail_box.pack_start (genre_label, false, false, 0);
        detail_box.pack_start (year_label, false, false, 0);
        detail_box.pack_end (shuffle_button, false, false, 0);

        var album_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        album_box.hexpand = true;
        album_box.margin = 12;
        album_box.pack_start (image_cover, false, false, 0);
        album_box.pack_start (detail_box, false, false, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (album_box, false, false, 0);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (main_box);

        add (scrolled);
    }
}