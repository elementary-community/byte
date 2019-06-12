public class Views.Tracks : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Gtk.Label time_label;
    public signal void go_back ();
    private int item_index;
    private int item_max;
    private Gee.ArrayList<Objects.Track?> all_tracks;

    private int tracks_number = 0;
    private uint64 tracks_time = 0;

    public Tracks () {} 

    construct {
        item_index = 0;
        item_max = 25;

        all_tracks = Byte.database.get_all_tracks_order_by (
            Byte.settings.get_enum ("tracks-sort"), 
            Byte.settings.get_boolean ("tracks-order-reverse")
        );

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
        sort_popover.reverse = Byte.settings.get_boolean ("tracks-order-reverse");

        listbox = new Gtk.ListBox (); 
        listbox.expand = true;

        var shuffle_button = new Gtk.Button.from_icon_name ("media-playlist-shuffle-symbolic", Gtk.IconSize.MENU);
        //shuffle_button.label = _("Shuffle");
        shuffle_button.margin = 6;
        shuffle_button.width_request = 85;
        shuffle_button.can_focus = false;
        //shuffle_button.image_position = Gtk.PositionType.LEFT;
        shuffle_button.valign = Gtk.Align.CENTER;
        shuffle_button.halign = Gtk.Align.END;
        shuffle_button.hexpand = true;
        shuffle_button.get_style_context ().add_class ("shuffle-button");
        shuffle_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        //shuffle_button.always_show_image = true;

        time_label = new Gtk.Label (null);
        time_label.get_style_context ().add_class ("h3");
        time_label.get_style_context ().add_class ("dim-label");

        var grid = new Gtk.Grid ();
        grid.margin_start = 6;
        grid.add (time_label);
        grid.add (shuffle_button);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.margin_top = 3;
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (listbox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 3;
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false);
        main_box.pack_start (grid, false, false);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        add_all_tracks ();
        get_realtive_time ();

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
            
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            all_tracks = Byte.database.get_all_tracks_order_by (mode, Byte.settings.get_boolean ("tracks-order-reverse"));

            add_all_tracks ();
        });

        sort_popover.order_reverse.connect ((reverse) => {
            Byte.settings.set_boolean ("tracks-order-reverse", reverse); 

            item_index = 0;
            item_max = 100;
            
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            all_tracks = Byte.database.get_all_tracks_order_by (
                Byte.settings.get_enum ("tracks-sort"), 
                Byte.settings.get_boolean ("tracks-order-reverse")
            );

            add_all_tracks ();
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

        Byte.database.adden_new_track.connect ((track) => {
            Idle.add (() => {
                add_track (track);

                return false;
            });
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
    }

    private void add_track (Objects.Track track) {
        var row = new Widgets.TrackRow (track);
        
        all_tracks.add (track);
        listbox.add (row);
        listbox.show_all ();
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

    private void get_realtive_time () {
        tracks_number = all_tracks.size;

        foreach (var item in all_tracks) {
            tracks_time = tracks_time + item.duration;
        }

        time_label.label = "%i Tracks - %s".printf (tracks_number, Byte.utils.get_relative_duration (tracks_time));

        print ("tracks_time: %s\n".printf (Byte.utils.get_relative_duration (tracks_time)));
        print ("size: %s\n".printf (tracks_number.to_string ()));
    }
}