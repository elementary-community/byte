public class Views.Albums : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private Gtk.FlowBox flowbox;

    public signal void go_back ();
    public Albums () {}

    construct {
        var back_button = new Gtk.Button.with_label (_("Back"));
        back_button.margin = 6;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Albums")));
        title_label.use_markup = true;
        title_label.valign = Gtk.Align.CENTER;
        title_label.get_style_context ().add_class ("h3");

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.margin = 6;
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var search_entry = new Gtk.SearchEntry ();
        search_entry.valign = Gtk.Align.CENTER;
        search_entry.width_request = 250;
        search_entry.get_style_context ().add_class ("search-entry");
        search_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_entry.placeholder_text = _("Your library");
        search_entry.no_show_all = true;
        search_entry.visible = false;

        var center_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        center_box.pack_start (title_label, false, false, 0);
        center_box.pack_start (search_entry, true, true, 0);

        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.pack_start (back_button, false, false, 0);
        header_box.set_center_widget (center_box);
        header_box.pack_end (search_button, false, false, 0);

        listbox = new Gtk.ListBox ();
        listbox.expand = true;

        flowbox = new Gtk.FlowBox ();
        flowbox.margin = 6;
        flowbox.row_spacing = 6;
        flowbox.homogeneous = true;

        flowbox.min_children_per_line = 3;
        flowbox.expand = true;

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
        //main_box.pack_start (search_entry, false, false, 0);
        main_box.pack_start (scrolled, true, true, 0);
        
        add (main_box);
        get_all_albums ();

        back_button.clicked.connect (() => {
            go_back ();
        });

        Byte.database.added_new_album.connect ((album) => {
            var child = new Widgets.AlbumChild (album);
            flowbox.add (child);

            flowbox.show_all ();
        });

        search_button.clicked.connect (() => {
            if (title_label.visible) {
                title_label.no_show_all = true;
                title_label.visible = false;

                search_entry.no_show_all = false;
                search_entry.visible = true;

                search_entry.grab_focus ();
            } else {
                title_label.no_show_all = false;
                title_label.visible = true;

                search_entry.no_show_all = true;
                search_entry.visible = false;
            }
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
