public class Views.Favorites : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Gtk.Label time_label;
    public signal void go_back ();
    private int item_index;
    private int item_max;
    private Gee.ArrayList<Objects.Track?> all_tracks;

    public Favorites () {} 

    construct {
        item_index = 0;
        item_max = 25;

        all_tracks = Byte.database.get_all_tracks_favorites (
            Byte.settings.get_enum ("track-sort"), 
            Byte.settings.get_boolean ("track-order-reverse")
        );

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");
        
        var back_button = new Gtk.Button.from_icon_name ("planner-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("planner-back-button");

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.label = _("Favorites");
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
        search_entry.hexpand = true;
        search_entry.margin = 6;
        search_entry.get_style_context ().add_class ("search-entry");
        search_entry.placeholder_text = _("Your library");

        var search_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        search_box.add (search_entry);
        search_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var search_revealer = new Gtk.Revealer ();
        search_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        search_revealer.add (search_box);
        search_revealer.reveal_child = false;

        var sort_button = new Gtk.ToggleButton ();
        sort_button.margin = 6;
        sort_button.can_focus = false;
        sort_button.add (new Gtk.Image.from_icon_name ("planner-sort-symbolic", Gtk.IconSize.MENU));
        sort_button.tooltip_text = _("Sort");
        sort_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        sort_button.get_style_context ().add_class ("sort-button");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (search_button);
        header_box.pack_end (sort_button, false, false, 0);

        var sort_popover = new Widgets.Popovers.Sort (sort_button);
        sort_popover.selected = Byte.settings.get_enum ("track-sort");
        sort_popover.reverse = Byte.settings.get_boolean ("track-order-reverse");
        sort_popover.radio_01_label = _("Title");
        sort_popover.radio_02_label = _("Artist");
        sort_popover.radio_03_label = _("Album");
        sort_popover.radio_04_label = _("Date Added");

        listbox = new Gtk.ListBox (); 
        listbox.expand = true;

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
        action_grid.column_spacing = 12;
        action_grid.add (play_button);
        action_grid.add (shuffle_button);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (listbox);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 14;
        separator.margin_end = 9;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 3;
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (search_revealer, false, false, 0);
        main_box.pack_start (action_grid, false, false);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        add_all_tracks ();

        back_button.clicked.connect (() => {
            go_back ();
        });

        search_button.clicked.connect (() => {
            if (search_revealer.reveal_child) {
                search_revealer.reveal_child = false;
                search_entry.text = "";
            } else {
                search_revealer.reveal_child = true;
                search_entry.grab_focus ();
            }            
        });

        search_entry.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                search_revealer.reveal_child = false;
                search_entry.text = "";
            }

            return false;
        });

        search_entry.activate.connect (() => {
            if (search_entry.text != "") {
                item_index = 0;
                item_max = 100;
                
                listbox.foreach ((widget) => {
                    widget.destroy (); 
                });

                all_tracks = Byte.database.get_all_tracks_favorites_search (search_entry.text.down ());

                add_all_tracks ();
            } else {
                item_index = 0;
                item_max = 100;
                
                listbox.foreach ((widget) => {
                    widget.destroy (); 
                });

                all_tracks = Byte.database.get_all_tracks_favorites (
                    Byte.settings.get_enum ("track-sort"), 
                    Byte.settings.get_boolean ("track-order-reverse")
                );

                add_all_tracks ();
            }
        });
        
        search_entry.search_changed.connect (() => {    
            if (search_entry.text != "") {
                item_index = 0;
                item_max = 100;
                
                listbox.foreach ((widget) => {
                    widget.destroy (); 
                });

                all_tracks = Byte.database.get_all_tracks_favorites_search (search_entry.text);

                add_all_tracks ();
            } else {
                item_index = 0;
                item_max = 100;
                
                listbox.foreach ((widget) => {
                    widget.destroy (); 
                });

                all_tracks = Byte.database.get_all_tracks_favorites (
                    Byte.settings.get_enum ("track-sort"), 
                    Byte.settings.get_boolean ("track-order-reverse")
                );

                add_all_tracks ();
            }
        });

        sort_button.toggled.connect (() => {
            if (sort_button.active) {
                sort_popover.show_all ();
            }
        });

        sort_popover.closed.connect (() => {
            sort_button.active = false;
        });

        sort_popover.mode_changed.connect ((mode) => {
            Byte.settings.set_enum ("track-sort", mode);

            item_index = 0;
            item_max = 100;
            
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            all_tracks = Byte.database.get_all_tracks_favorites (mode, Byte.settings.get_boolean ("track-order-reverse"));

            add_all_tracks ();
        });

        sort_popover.order_reverse.connect ((reverse) => {
            Byte.settings.set_boolean ("track-order-reverse", reverse); 

            item_index = 0;
            item_max = 100;
            
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            all_tracks = Byte.database.get_all_tracks_favorites (
                Byte.settings.get_enum ("track-sort"), 
                Byte.settings.get_boolean ("track-order-reverse")
            );

            add_all_tracks ();
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

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;
            
            Byte.utils.set_items (
                all_tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });

        scrolled.edge_reached.connect((pos)=> {
            if (pos == Gtk.PositionType.BOTTOM) {
                
                item_index = item_max;
                item_max = item_max + 100;

                if (item_max > all_tracks.size) {
                    item_max = all_tracks.size;
                }

                add_all_tracks ();
            }
        });

        Byte.database.updated_track_favorite.connect ((track, favorite) => {
            if (track_exists (track) == false) {
                if (favorite == 1) {
                    track._id = all_tracks.size + 1;
                    all_tracks.add (track);
                }
            } else {
                if (favorite == 0) {
                    listbox.foreach ((widget) => {
                        var item = widget as Widgets.TrackRow;
                        if (item.track.id == track.id) {
                            widget.destroy (); 
                            all_tracks.remove (track);
                        }
                    });
                }
            }
        });
    }
    
    private bool track_exists (Objects.Track track) {
        foreach (var item in all_tracks) {
            if (item.id == track.id) {
                return true;
            }
        }

        return false;
    }
    public void add_all_tracks () {
        if (item_max > all_tracks.size) {
            item_max = all_tracks.size;
        }

        for (int i = item_index; i < item_max; i++) {
            var row = new Widgets.TrackRow (all_tracks [i]);

            listbox.add (row);
            listbox.show_all ();
        }   
    }
}