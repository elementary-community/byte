public class Views.Artists : Gtk.EventBox {
    private Gtk.ListBox listbox;
    public signal void go_back ();

    private bool is_initialized = false;
    
    public Artists () {

    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class ("w-round");

        var back_button = new Gtk.Button.from_icon_name ("planner-arrow-back-symbolic", Gtk.IconSize.MENU);
        back_button.can_focus = false;
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        back_button.get_style_context ().add_class ("label-color-primary");

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Artists")));
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

        listbox = new Gtk.ListBox ();
        listbox.expand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (listbox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);

        back_button.clicked.connect (() => {
            go_back ();
        });

        Byte.database.added_new_artist.connect ((track) => {
            Idle.add (() => {
                add_artist (track);

                return false;
            });
        });

        Byte.database.reset_library.connect (() => {
            listbox.foreach ((widget) => {
                widget.destroy (); 
            });
        });
    }

    private void add_artist (Objects.Artist artist) {
        if (artist.id != 0) {
            var row = new Widgets.ArtistRow (artist);
            listbox.add (row);
        
            listbox.show_all ();
        }
    }

    public void get_all_artists () {
        if (is_initialized == false) {
            Timeout.add (120, () => {
                new Thread<void*> ("get_all_artists", () => {
                    var all_artists = new Gee.ArrayList<Objects.Artist?> ();
                    all_artists = Byte.database.get_all_artists ();
        
                    foreach (var item in all_artists) {
                        Idle.add (() => {
                            add_artist (item);
        
                            return false;
                        });    
                    }
        
                    is_initialized = true;
                    return null;
                });

                return false;
            });
        }
    }
}