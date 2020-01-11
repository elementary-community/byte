public class Widgets.Files : Gtk.EventBox {
    private Widgets.SearchEntry search_entry;
    private Gtk.Revealer search_revealer;

    private Gee.ArrayList<string> nav;
    private string root { get; set; default = Byte.settings.get_string ("library-location"); }

    construct {
        nav = new Gee.ArrayList<string> ();
        nav.add (root);

        var previous_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.MENU);
        previous_button.can_focus = false;
        previous_button.sensitive = false;
        previous_button.margin = 3;
        previous_button.margin_start = 6;
        previous_button.get_style_context ().add_class ("flat");
        previous_button.get_style_context ().add_class ("label-color-primary");

        var nav_label = new Gtk.Label (root.replace ("%20", " ").substring (7));
        nav_label.tooltip_text = root.replace ("%20", " ").substring (7);
        nav_label.ellipsize = Pango.EllipsizeMode.START;
        nav_label.halign = Gtk.Align.CENTER;
        nav_label.hexpand = true;

        var search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.MENU);
        search_button.margin = 3;
        search_button.can_focus = false;
        search_button.get_style_context ().add_class ("label-color-primary");
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var nav_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        nav_box.get_style_context ().add_class (Gtk.STYLE_CLASS_BACKGROUND);
        nav_box.hexpand = true;
        nav_box.pack_start (previous_button, false, false, 0);
        //nav_box.pack_start (next_button, false, false, 0);
        nav_box.set_center_widget (nav_label);
        //nav_box.pack_end (search_button, false, false, 0);

        search_entry = new Widgets.SearchEntry ();
        search_entry.tooltip_text = _("Search by title, artist and album");
        search_entry.placeholder_text = _("Search by title, artist and album");

        var search_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        search_box.get_style_context ().add_class (Gtk.STYLE_CLASS_BACKGROUND);
        search_box.add (search_entry);
        search_box.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        search_revealer = new Gtk.Revealer ();
        search_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        search_revealer.add (search_box);
        search_revealer.reveal_child = false;

        var listbox_stack = new Gtk.Stack ();
        listbox_stack.expand = true;
        listbox_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        listbox_stack.add_named (new Widget.FilesListBox (root), root);

        var files_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        files_box.expand = true;
        files_box.pack_start (nav_box, false, true, 0);
        files_box.pack_start (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
        files_box.pack_start (search_revealer, false, false, 0);
        files_box.pack_start (listbox_stack, false, true, 0);

        add (files_box);
        show_all ();
        
        previous_button.clicked.connect (() => {
            if (nav.size > 0) {
                nav.remove_at (nav.size - 1);
                listbox_stack.visible_child_name = nav [nav.size - 1];

                nav_label.label = nav [nav.size - 1].replace ("%20", " ").substring (7);
                nav_label.tooltip_text = nav [nav.size - 1].replace ("%20", " ").substring (7);

                if (nav.size - 1 <= 0) {
                    previous_button.sensitive = false;
                }
            } else {
                listbox_stack.visible_child_name = root;

                nav_label.label = root.replace ("%20", " ").substring (7);
                nav_label.tooltip_text = root.replace ("%20", " ").substring (7);
            }
        });

        Byte.utils.nav_to.connect ((title, uri) => {
            listbox_stack.add_named (new Widget.FilesListBox (uri), uri);
            listbox_stack.visible_child_name = uri;

            nav_label.label = title;
            nav_label.tooltip_text = uri.replace ("%20", " ").substring (7);

            nav.add (uri);
            previous_button.sensitive = true;
        });

        search_entry.search_changed.connect (() => {
            var widget = (Widget.FilesListBox) listbox_stack.visible_child;
            print ("Search: %s\n".printf (search_entry.text));
            widget.filter (search_entry.text);
        });
    }

    public void reveal_search () {
        if (search_revealer.reveal_child) {
            search_revealer.reveal_child = false;
            search_entry.text = "";
        } else {
            search_revealer.reveal_child = true;
            search_entry.grab_focus ();
        }
    }
}

public class Widget.FilesListBox : Gtk.Grid {
    public string uri { get; construct; }

    private Gtk.ListBox folders_listbox;
    private Gtk.ListBox tracks_listbox;

    public FilesListBox (string uri) {
        Object (
            uri: uri
        );
    }

    construct {
        folders_listbox = new Gtk.ListBox (); 
        folders_listbox.expand = true;
        folders_listbox.set_sort_func ((row1, row2) => {
            var item1 = (Widgets.FolderRow) row1;
            var item2 = (Widgets.FolderRow) row2;

            if (item1.title > item2.title) {
                return 1;
            } else {
                return 0;
            }
        });

        tracks_listbox = new Gtk.ListBox (); 
        tracks_listbox.expand = true;
        tracks_listbox.set_sort_func ((row1, row2) => {
            var item1 = (Widgets.TrackRow) row1;
            var item2 = (Widgets.TrackRow) row2;

            if (item1.track.title > item2.track.title) {
                return 1;
            } else {
                return 0;
            }
        });

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.valign = Gtk.Align.START;
        grid.add (folders_listbox);
        grid.add (tracks_listbox);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scrolled.expand = true;
        scrolled.add (grid);

        add (scrolled);
        show_all ();
        scan_folder (uri);

        folders_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.FolderRow;
            Byte.utils.nav_to (item.title, item.uri);
        });

        tracks_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;

            var tracks = new Gee.ArrayList<Objects.Track?> ();
            int count = 0;
            tracks_listbox.foreach ((row) => {
                var i = row as Widgets.TrackRow;

                i.track.track_order = count;
                tracks.add (i.track);
                
                count++;
            });

            Byte.utils.set_items (
                tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });
    }

    private void found_music_directory (bool is_directory, string title, string uri) {
        Idle.add (() => {
            if (is_directory) {
                var row = new Widgets.FolderRow (title, uri);
                folders_listbox.add (row);
                folders_listbox.show_all ();
            } else {
                var track = Byte.database.get_track_by_path (uri);
                var row = new Widgets.TrackRow (track);
                tracks_listbox.add (row);
                tracks_listbox.show_all ();
            }

            return false;
        });
    }

    private void scan_folder (string uri) {
        new Thread<void*> ("scan_folder", () => {
            File directory = File.new_for_uri (uri.replace ("#", "%23"));
            try {
                var children = directory.enumerate_children ("standard::*," + FileAttribute.STANDARD_CONTENT_TYPE + "," + FileAttribute.STANDARD_IS_HIDDEN + "," + FileAttribute.STANDARD_IS_SYMLINK + "," + FileAttribute.STANDARD_SYMLINK_TARGET, GLib.FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                while ((file_info = children.next_file ()) != null) {
                    if (file_info.get_is_hidden ()) {
                        continue;
                    }

                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        // Without usleep it crashes on smb:// protocol
                        if (!directory.get_uri ().has_prefix ("file://")) {
                            Thread.usleep (1000000);
                        }

                        found_music_directory (
                            true,
                            file_info.get_name (),
                            directory.get_uri () + "/" + file_info.get_name ()
                        );
                    } else {
                        string mime_type = file_info.get_content_type ();
                        if (is_audio_file (mime_type)) {
                            found_music_directory (
                                false,
                                "",
                                directory.get_uri () + "/" + file_info.get_name ()
                            );
                        }
                    }
                }

                children.close ();
                children.dispose ();
            } catch (Error err) {
                warning ("%s\n%s", err.message, uri);
            }

            directory.dispose ();
            return null;
        });
    }

    private static bool is_audio_file (string mime_type) {
        return mime_type.has_prefix ("audio/") && !mime_type.contains ("x-mpegurl") && !mime_type.contains ("x-scpls");
    }

    public void filter (string term) {
        folders_listbox.set_filter_func ((row) => {
            var item = (Widgets.FolderRow) row;
            return term.down () in item.title.down ();
        });

        tracks_listbox.set_filter_func ((row) => {
            var item = (Widgets.TrackRow) row;
            return term.down () in item.track.title.down ();
        });
    }
}