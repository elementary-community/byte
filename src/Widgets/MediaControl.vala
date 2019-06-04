public class Widgets.MediaControl : Gtk.EventBox {
    private Granite.SeekBar timeline;
    private Gtk.Label title_label;
    private Gtk.Label artist_album_label;

    private Gtk.Button favorite_button;
    private Gtk.Button lyric_button;
    
    private Gtk.Image icon_favorite;
    private Gtk.Image icon_no_favorite;

    public MediaControl () {

    }
    
    construct {
        get_style_context ().add_class ("media-control");

        icon_favorite = new Gtk.Image.from_icon_name ("emblem-favorite-symbolic", Gtk.IconSize.MENU);
        icon_no_favorite = new Gtk.Image.from_icon_name ("face-heart-symbolic", Gtk.IconSize.MENU);

        timeline = new Granite.SeekBar (0);
        timeline.margin_start = 6;
        timeline.margin_top = 9;
        timeline.margin_end = 6;
        timeline.get_style_context ().remove_class ("seek-bar");
        timeline.get_style_context ().add_class ("byte-seekbar");

        title_label = new Gtk.Label ("<b>I Love My Friends</b>");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.use_markup = true;

        artist_album_label = new Gtk.Label ("Foster the People - Torches");
        artist_album_label.ellipsize = Pango.EllipsizeMode.END;
        artist_album_label.use_markup = true;

        favorite_button = new Gtk.Button ();
        favorite_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        favorite_button.get_style_context ().add_class ("button-color");
        favorite_button.can_focus = false;
        favorite_button.valign = Gtk.Align.CENTER;
        favorite_button.image = icon_no_favorite;

        lyric_button = new Gtk.Button.from_icon_name ("text-x-generic-symbolic", Gtk.IconSize.MENU);
        lyric_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        lyric_button.get_style_context ().add_class ("button-color");
        lyric_button.can_focus = false;
        lyric_button.valign = Gtk.Align.CENTER;

        var metainfo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        metainfo_box.add (title_label);
        metainfo_box.add (artist_album_label);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.margin = 3;
        header_box.margin_bottom = 6;
        header_box.pack_start (favorite_button, false, false, 0);
        header_box.pack_start (metainfo_box, true, true, 0);
        header_box.pack_end (lyric_button, false, false, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (timeline, false, false, 0);
        main_box.pack_start (header_box, false, false, 0);
        
        add (main_box);

        favorite_button.clicked.connect (() => {
            if (favorite_button.image == icon_favorite) {
                favorite_button.image = icon_no_favorite;
            } else {
                favorite_button.image = icon_favorite;
            }
        });
    }
}