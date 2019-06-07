public class Views.Tracks : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Gtk.Revealer loading_revealer;
    public signal void go_back ();

    private int item_index;
    private int item_max;
    private bool is_completed = false;
    private Gee.ArrayList<Objects.Track?> all_tracks;
    public Tracks () {
    }

    construct {
        item_index = 0;
        item_max = 100;

        all_tracks = new Gee.ArrayList<Objects.Track?> ();
        all_tracks = Byte.database.get_all_tracks_order_by (Byte.settings.get_enum ("tracks-sort"));

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");
        
        var back_button = new Gtk.Button.from_icon_name ("planner-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("planner-back-button");

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Tracks")));
        title_label.use_markup = true;
        title_label.valign = Gtk.Align.CENTER;
        title_label.get_style_context ().add_class ("h3");

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.label = _("Songs");
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

        var sort_button = new Gtk.ToggleButton ();
        sort_button.margin = 6;
        sort_button.can_focus = false;
        sort_button.add (new Gtk.Image.from_icon_name ("planner-sort-symbolic", Gtk.IconSize.MENU));
        sort_button.tooltip_text = _("Sort");
        sort_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        sort_button.get_style_context ().add_class ("sort-button");

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_stack);
        header_box.pack_end (sort_button, false, false, 0);

        var sort_popover = new Widgets.Popovers.Sort (sort_button);
        sort_popover.selected = Byte.settings.get_enum ("tracks-sort");

        listbox = new Gtk.ListBox (); 
        listbox.expand = true;

        var play_button = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);
        play_button.label = _("Play");
        play_button.width_request = 150;
        play_button.can_focus = false;
        play_button.image_position = Gtk.PositionType.LEFT;
        play_button.valign = Gtk.Align.CENTER;
        play_button.hexpand = true;
        play_button.get_style_context ().add_class ("home-button");
        play_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        play_button.always_show_image = true;

        var shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.MENU);
        shuffle_button.label = _("Shuffle");
        shuffle_button.width_request = 150;
        shuffle_button.can_focus = false;
        shuffle_button.image_position = Gtk.PositionType.LEFT;
        shuffle_button.valign = Gtk.Align.CENTER;
        shuffle_button.hexpand = true;
        shuffle_button.get_style_context ().add_class ("home-button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        shuffle_button.always_show_image = true;

        var action_grid = new Gtk.Grid ();
        action_grid.column_homogeneous = true;
        action_grid.valign = Gtk.Align.CENTER;
        action_grid.hexpand = true;
        action_grid.margin = 6;
        action_grid.column_spacing = 6;
        action_grid.add (play_button);
        action_grid.add (shuffle_button);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (listbox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 3;
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (action_grid, false, false);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        
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
            listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;
                return search_entry.text.down () in item.track.title.down () ||
                    search_entry.text.down () in item.track.artist_name.down () ||
                    search_entry.text.down () in item.track.album_title.down ();
            });
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
            Byte.settings.set_enum ("tracks-sort", mode);

            item_index = 0;
            item_max = 100;
            is_completed = false;
            
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            all_tracks = Byte.database.get_all_tracks_order_by (mode);

            add_all_tracks ();
        });

        play_button.clicked.connect (() => {
            all_tracks = Byte.database.get_all_tracks_order_by (Byte.settings.get_enum ("tracks-sort"));
            Byte.utils.set_items (all_tracks, "shuffle_off");
        });

        shuffle_button.clicked.connect (() => {
            all_tracks = Byte.database.get_all_tracks_order_by (Byte.settings.get_enum ("tracks-sort"));
            Byte.utils.set_items (all_tracks, "shuffle_on");
        });

        Byte.database.adden_new_track.connect ((track) => {
            Idle.add (() => {
                add_track (track);

                return false;
            });
        });

        Byte.player.current_track_changed.connect ((track) => {
            listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;
                if (track.id == item.track.id) {
                    listbox.select_row (row);
                }
                
                return true;
            });
        });

        scrolled.edge_reached.connect((pos)=> {
            if (pos == Gtk.PositionType.BOTTOM) {
                
                item_index = item_max;
                item_max = item_max + 100;

                if (item_max > all_tracks.size) {
                    item_max = all_tracks.size;
                }

                if (item_index == item_max) {
                    is_completed = true;
                }

                add_all_tracks ();
            }
        });
    }

    private void add_track (Objects.Track track) {
        var row = new Widgets.TrackRow (track);
        
        listbox.add (row);
        listbox.show_all ();
    }

    public void add_all_tracks () {
        if (is_completed == false) {
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
}