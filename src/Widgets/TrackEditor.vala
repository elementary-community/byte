public class Widgets.TrackEditor : Gtk.EventBox {
    private Gtk.Entry title_entry;
    private Gtk.Entry artist_entry;
    private Gtk.Entry album_entry;
    private Gtk.Entry genre_entry;
    private Gtk.SpinButton year_spin;
    private Gtk.ToggleButton cover_button;
    private Gtk.Image cover_image;

    public signal void on_signal_back_button ();
    public Objects.Track track {
        set {
            Objects.Track _track = value;

            title_entry.text = _track.title;
            artist_entry.text = _track.artist;
            album_entry.text = _track.album;
            genre_entry.text = _track.genre;
            year_spin.value = (double) _track.year;
        }
    }

    public TrackEditor () {
        Object (

        );
    }

    construct {
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.can_focus = false;
        back_button.valign = Gtk.Align.CENTER;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var mode_button = new Granite.Widgets.ModeButton ();
        mode_button.hexpand = true;
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.halign = Gtk.Align.CENTER;

        mode_button.append_text (_("Information"));
        mode_button.append_text (_("Lyric"));
        mode_button.selected = 0;

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.margin = 6;
        top_box.hexpand = true;
        top_box.pack_start (back_button, false, false, 0);
        top_box.set_center_widget (mode_button);

        var main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.margin = 12;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (get_information_widget (), "information");
        main_stack.add_named (get_lyric_widget (), "lyric");

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        main_grid.add (top_box);
        main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        main_grid.add (mode_button);
        main_grid.add (main_stack);
        //main_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        //main_grid.add (top_box);

        add (main_grid);

        back_button.clicked.connect (() => {
            on_signal_back_button ();
        });

        mode_button.mode_changed.connect ((widget) => {
            if (mode_button.selected == 0) {
                main_stack.visible_child_name = "information";
            } else if (mode_button.selected == 1){
                main_stack.visible_child_name = "lyric";
            }
        });
    }

    private Gtk.Widget get_information_widget () {
        cover_button = new Gtk.ToggleButton ();
        cover_button.hexpand = true;
        cover_button.halign = Gtk.Align.CENTER;
        cover_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        cover_image = new Gtk.Image ();
        cover_image.gicon = new ThemedIcon ("byte-drag-music");
        cover_image.pixel_size = 64;

        cover_button.add (cover_image);

        title_entry = new Gtk.Entry ();
        title_entry.placeholder_text = "Title";

        artist_entry = new Gtk.Entry ();
        artist_entry.placeholder_text = "Artist";

        album_entry = new Gtk.Entry ();
        album_entry.placeholder_text = "album";

        genre_entry = new Gtk.Entry ();
        genre_entry.placeholder_text = "Genre";

        year_spin = new Gtk.SpinButton.with_range (1, 3000, 1);

        var grid = new Gtk.Grid ();
        grid.expand = true;
        grid.orientation = Gtk.Orientation.VERTICAL;
        //grid.row_spacing = 6;
        //grid.column_spacing = 6;
        grid.attach (cover_button,                          0, 0, 1, 1);
        grid.attach (new Granite.HeaderLabel (_("Title")),  0, 1, 1, 1);
        grid.attach (title_entry,                           0, 2, 1, 1);
        grid.attach (new Granite.HeaderLabel (_("Artist")), 0, 3, 1, 1);
        grid.attach (artist_entry,                          0, 4, 1, 1);
        grid.attach (new Granite.HeaderLabel (_("Album")),  0, 5, 1, 1);
        grid.attach (album_entry,                           0, 6, 1, 1);
        grid.attach (new Granite.HeaderLabel (_("Genre")),  0, 7, 1, 1);
        grid.attach (genre_entry,                           0, 8, 1, 1);
        grid.attach (new Granite.HeaderLabel (_("Year")),   0, 9, 1, 1);
        grid.attach (year_spin,                             0, 10, 1, 1);

        return grid;
    }

    private Gtk.Widget get_lyric_widget () {
        var lyric_textview = new Gtk.TextView ();
        lyric_textview.justification = Gtk.Justification.CENTER;
        lyric_textview.expand = true;
        lyric_textview.get_style_context ().add_class ("lyric");

        var grid = new Gtk.Grid ();
        grid.expand = true;
        grid.add (lyric_textview);

        return grid;
    }
}
