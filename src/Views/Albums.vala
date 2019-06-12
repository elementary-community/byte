public class Views.Albums : Gtk.EventBox {
    private Gtk.ListBox listbox;
    public signal void go_back ();
    public signal void go_album (Objects.Album album);

    private bool is_initialized = false;

    public Albums () {
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

        listbox = new Gtk.ListBox ();
        listbox.vexpand = true;

        listbox.set_filter_func ((child) => {
            var item = child as Widgets.AlbumRow;
            return search_entry.text.down () in item.album.title.down () ||
                search_entry.text.down () in item.album.artist_name.down ();
        });

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

        search_button.clicked.connect (() => {
            if (center_stack.visible_child_name == "title_label") {
                center_stack.visible_child_name = "search_entry";
                search_entry.grab_focus ();
            } else {
                center_stack.visible_child_name = "title_label";
            }
        });

        search_entry.search_changed.connect (() => {
            listbox.invalidate_filter ();
        });

        search_entry.key_release_event.connect ((key) => {
            if (key.keyval == 65307) {
                center_stack.visible_child_name = "title_label";
            }

            return false;
        });

        search_entry.focus_out_event.connect (() => {
            center_stack.visible_child_name = "title_label";
            return false;
        });

        listbox.row_activated.connect ((row) => {
            var item = row as Widgets.AlbumRow;
            go_album (item.album);
        });

        Byte.database.added_new_album.connect ((album) => {
            Idle.add (() => {
                add_album (album);

                return false;
            });
        });
    }

    private void add_album (Objects.Album album) {
        if (album.id != 0) {
            var row = new Widgets.AlbumRow (album);
            listbox.add (row);
            listbox.show_all ();
        }
    }

    public void get_all_albums () {
        Timeout.add (120, () => {
            if (is_initialized == false) {
                new Thread<void*> ("get_all_albums", () => {
                    var all_albums = new Gee.ArrayList<Objects.Album?> ();
                    all_albums = Byte.database.get_all_albums ();
        
                    foreach (var item in all_albums) {
                        Idle.add (() => {
                            add_album (item);
            
                            return false;
                        });
                    }

                    print ("Termino\n");
                    is_initialized = true;
                    return null;
                }); 
            }

            return false;
        });
    }
}
