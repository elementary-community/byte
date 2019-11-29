public class Widgets.QuickFind : Gtk.Revealer {
    private Gtk.ListBox radios_listbox;
    public Widgets.SearchEntry search_entry;
    public bool reveal {
        set {
            if (value) {
                reveal_child = true;
                search_entry.grab_focus ();
            } else {
                reveal_child = false;
            }
        }
    }
    public QuickFind () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        margin_top = 12;
        valign = Gtk.Align.START;
        halign = Gtk.Align.CENTER;
        reveal_child = false;
    }

    construct {
        search_entry = new Widgets.SearchEntry ();
        search_entry.margin = 0;
        //search_entry.get_style_context ().add_class ("search-entry");
        search_entry.placeholder_text = _("Quick find");

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.can_focus = false;
        cancel_button.valign = Gtk.Align.CENTER;
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        cancel_button.get_style_context ().add_class ("quick-find-cancel");

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        top_box.margin = 9;
        top_box.pack_start (search_entry, false, true, 0);
        top_box.pack_end (cancel_button, false, false, 0);

        var mode_button = new Granite.Widgets.ModeButton ();
        //mode_button.get_style_context ().add_class ("quick-find-modebutton");
        mode_button.margin = 9;
        mode_button.margin_top = 0;
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.append_text (_("Library"));
        mode_button.append_text (_("Radios"));
        mode_button.selected = 1;

        var stack = new Gtk.Stack ();
        stack.expand = true;
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        //stack.add_named (get_search_library_widget (), "search_library");
        stack.add_named (get_search_radio_widget (), "search_radio");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.height_request = 450;
        main_box.width_request = 300;
        main_box.get_style_context ().add_class ("quick-find");
        main_box.pack_start (top_box, false, false, 0);
        //main_box.pack_start (mode_button, false, false, 0);
        main_box.pack_start (stack, false, true, 0);
        
        add (main_box);

        mode_button.mode_changed.connect (() => {
            if (mode_button.selected == 0) {
                stack.visible_child_name = "search_library";
            } else {
                stack.visible_child_name = "search_radio";
            }
        });

        cancel_button.clicked.connect (() => {
            reveal = false;
        });

        search_entry.activate.connect (() => {
            if (mode_button.selected == 0) {

            } else {
                Byte.radio_browser.get_radios_by_name (search_entry.text);
            }
        });
    }

    private Gtk.Widget get_search_library_widget () {
        var artists_listbox = new Gtk.ListBox ();
        artists_listbox.get_style_context ().add_class ("background");
        artists_listbox.expand = true;   

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (artists_listbox, true, true, 0);

        return main_box;
    }

    private Gtk.Widget get_search_radio_widget () {
        // Toast
        var toast = new Granite.Widgets.Toast (_("The radio station was added correctly"));

        // Radios View
        radios_listbox = new Gtk.ListBox ();
        radios_listbox.get_style_context ().add_class ("background");
        radios_listbox.expand = true;

        var radios_spinner = new Gtk.Spinner ();
        radios_spinner.halign = Gtk.Align.CENTER;
        radios_spinner.valign = Gtk.Align.CENTER;
        radios_spinner.expand = true;
        radios_spinner.active = true;
        radios_spinner.start ();

        var alert_view = new Widgets.AlertView (
            _("Discover…"),
            _("Search your favorite radios"),
            "edit-find-symbolic"
        );

        var radio_stack = new Gtk.Stack ();
        radio_stack.expand = true;
        radio_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        radio_stack.add_named (alert_view, "radio_alert_grid");
        radio_stack.add_named (radios_spinner, "radios_spinner");
        radio_stack.add_named (radios_listbox, "radios_listbox");
        
        var radio_scrolled = new Gtk.ScrolledWindow (null, null);
        radio_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        radio_scrolled.expand = true;
        radio_scrolled.add (radio_stack);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (radio_scrolled, true, true, 0);
        main_box.pack_end (toast, false, false, 0);

        Byte.radio_browser.item_loaded.connect ((item) => {
            var row = new Widgets.RadioSearchRow (item);

            row.send_notification_error.connect (() => {
                toast.title = _("The radio station is already added");
                toast.send_notification ();
            });

            radios_listbox.add (row);
            radios_listbox.show_all ();
        });

        Byte.radio_browser.started.connect (() => {
            radio_stack.visible_child_name = "radios_spinner";

            radios_listbox.foreach((widget) => {
                widget.destroy (); 
            });
        });

        Byte.radio_browser.finished.connect (() => {
            int c = 0;

            radios_listbox.foreach ((widget) => {
                c++;
            });

            if (c > 0) {
                radio_stack.visible_child_name = "radios_listbox";
            } else {
                radio_stack.visible_child_name = "radio_alert_grid";
            }
        });

        Byte.database.adden_new_radio.connect ((radio) => {
            toast.title = _("The radio station was added correctly");
            toast.send_notification ();
        });

        return main_box;
    }
}
