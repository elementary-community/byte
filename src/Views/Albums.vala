public class Views.Albums : Gtk.EventBox {
    private Gtk.FlowBox flowbox;
    public signal void go_back ();

    public Albums () {
        add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
    }

    construct {
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

        flowbox = new Gtk.FlowBox ();
        flowbox.margin = 6;
        flowbox.row_spacing = 6;
        flowbox.homogeneous = true;
        flowbox.min_children_per_line = 2;
        flowbox.expand = true;
        flowbox.valign = Gtk.Align.START;

        flowbox.set_filter_func ((child) => {
            var item = child as Widgets.AlbumChild;
            return search_entry.text.down () in item.album.title.down () ||
                search_entry.text.down () in item.album.artist_name.down ();
        });

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.get_style_context ().add_class ("w-round");
        scrolled.expand = true;
        scrolled.add (flowbox);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        main_box.get_style_context ().add_class ("w-round");
        main_box.expand = true;
        main_box.pack_start (header_box, false, false, 0);
        main_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        get_all_albums ();

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

        Byte.database.added_new_album.connect ((album) => {
            if (album.id != 0) {
                var child = new Widgets.AlbumChild (album);
                flowbox.add (child);

                flowbox.show_all ();
            }
        });

        search_entry.search_changed.connect (() => {
            flowbox.invalidate_filter ();
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
        
        this.enter_notify_event.connect ((event) => {
            var select_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.HAND2);
            var window = Gdk.Screen.get_default ().get_root_window ();

            window.cursor = select_cursor;
            return false;
        });

        this.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            var select_cursor = new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.ARROW);
            var window = Gdk.Screen.get_default ().get_root_window ();

            window.cursor = select_cursor;

            return false;
        });
    }

    private void get_all_albums () {
        var all_albums = new Gee.ArrayList<Objects.Album?> ();
        all_albums = Byte.database.get_all_albums ();

        foreach (var item in all_albums) {
            var child = new Widgets.AlbumChild (item);
            flowbox.add (child);
        }

        flowbox.show_all ();
    }
}
