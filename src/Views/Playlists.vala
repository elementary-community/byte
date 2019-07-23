public class Views.Playlists : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Widgets.NewPlaylist new_playlist;

    public signal void go_back ();
    public signal void go_playlist (Objects.Playlist playlist);

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
        back_button.get_style_context ().add_class ("label-color-primary");

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.label = _("Playlists");
        search_button.can_focus = false;
        search_button.image_position = Gtk.PositionType.LEFT;
        search_button.valign = Gtk.Align.CENTER;
        search_button.halign = Gtk.Align.CENTER;
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_button.get_style_context ().add_class ("h3");
        search_button.get_style_context ().add_class ("label-color-primary");
        search_button.always_show_image = true;

        var add_button = new Gtk.ToggleButton ();
        add_button.can_focus = false;
        add_button.valign = Gtk.Align.CENTER;
        add_button.halign = Gtk.Align.CENTER;
        add_button.margin = 6;
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        add_button.get_style_context ().add_class ("label-color-primary");
        add_button.tooltip_text = _("Add New Playlist");
        add_button.add (new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR));

        var add_popover = new Widgets.Popovers.NewPlaylist (add_button);

        var search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;
        search_entry.width_request = 250;
        search_entry.get_style_context ().add_class ("search-entry");
        search_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_entry.placeholder_text = _("Your library");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (search_button);
        header_box.pack_end (add_button, false, false, 0);

        listbox = new Gtk.ListBox (); 
        listbox.expand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.margin_top = 3;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (listbox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 3;
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        add_all_items ();

        back_button.clicked.connect (() => {
            go_back ();
        });

        add_button.toggled.connect (() => {
            if (add_button.active) {
                add_popover.show_all ();
                add_popover.title_entry.grab_focus ();
            }
        });
  
        add_popover.closed.connect (() => {
            add_button.active = false;
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
            var item = row as Widgets.PlaylistRow;
            go_playlist (item.playlist);
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