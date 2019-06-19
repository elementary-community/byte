public class Views.Playlists : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Widgets.NewPlaylist new_playlist;
    public signal void go_back ();

    private int item_index;
    private int item_max;

    private Gee.ArrayList<Objects.Playlist?> all_items;

    public Playlists () {} 

    construct {
        item_index = 0;
        item_max = 25;

        all_items = Byte.database.get_all_playlists ();

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");
        
        var back_button = new Gtk.Button.from_icon_name ("planner-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("planner-back-button");

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.label = _("Playlists");
        search_button.can_focus = false;
        search_button.image_position = Gtk.PositionType.LEFT;
        search_button.valign = Gtk.Align.CENTER;
        search_button.halign = Gtk.Align.CENTER;
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_button.get_style_context ().add_class ("h3");
        search_button.get_style_context ().add_class ("search-title");
        search_button.always_show_image = true;

        var search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;
        search_entry.width_request = 250;
        search_entry.get_style_context ().add_class ("search-entry");
        search_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_entry.placeholder_text = _("Your library");

        var center_stack = new Gtk.Stack ();
        center_stack.hexpand = true;
        center_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        center_stack.add_named (search_button, "search_button");
        center_stack.add_named (search_entry, "search_entry");
        
        center_stack.visible_child_name = "search_button";

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_stack);

        new_playlist = new Widgets.NewPlaylist ();

        listbox = new Gtk.ListBox (); 
        listbox.expand = true;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.pack_start (new_playlist, false, false);
        box.pack_start (listbox, true, true, 0);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.margin_top = 3;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 3;
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        add_all_items ();

        back_button.clicked.connect (() => {
            go_back ();
        });

        search_button.clicked.connect (() => {
            center_stack.visible_child_name = "search_entry";
            search_entry.grab_focus ();
        });

        search_entry.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                center_stack.visible_child_name = "search_button";
            }

            return false;
        });

        search_entry.focus_out_event.connect (() => {
            center_stack.visible_child_name = "search_button";
            return false;
        });

        search_entry.search_changed.connect (() => {
            /*
            listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;
                return search_entry.text.down () in item.track.title.down () ||
                    search_entry.text.down () in item.track.artist_name.down () ||
                    search_entry.text.down () in item.track.album_title.down ();
            });
            */
        });


        listbox.row_activated.connect ((row) => {
            /*
            var item = row as Widgets.AlbumRow;
            go_album (item.album);
            */
        });

        Byte.database.adden_new_playlist.connect ((playlist) => {
            Idle.add (() => {
                add_item (playlist);

                return false;
            });
        });

        scrolled.edge_reached.connect((pos)=> {
            if (pos == Gtk.PositionType.BOTTOM) {
                
                item_index = item_max;
                item_max = item_max + 100;

                if (item_max > all_items.size) {
                    item_max = all_items.size;
                }

                //add_all_items ();
            }
        });
    }

    private void add_item (Objects.Playlist playlist) {
        var row = new Widgets.PlaylistRow (playlist);
        
        all_items.add (playlist);
        listbox.add (row);
        listbox.show_all ();
    }

    public void add_all_items () {
        if (item_max > all_items.size) {
            item_max = all_items.size;
        }

        for (int i = item_index; i < item_max; i++) {
            var row = new Widgets.PlaylistRow (all_items [i]);

            listbox.add (row);
            listbox.show_all ();
        }   
    }
}