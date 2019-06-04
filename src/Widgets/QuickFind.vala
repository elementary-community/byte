public class Widgets.QuickFind : Gtk.Revealer {
    public Gtk.SearchEntry search_entry;
    
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
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        margin_top = 12;
        valign = Gtk.Align.START;
        halign = Gtk.Align.CENTER;
        reveal_child = false;
        transition_duration = 300;
    }

    construct {
        search_entry = new Gtk.SearchEntry ();
        search_entry.get_style_context ().add_class ("quick-find-entry");
        search_entry.placeholder_text = _("Quick find");

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.set_focus_on_click (false);
        cancel_button.valign = Gtk.Align.CENTER;
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        cancel_button.get_style_context ().add_class ("quick-find-cancel");

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        top_box.margin = 6;
        top_box.pack_start (search_entry, true, true, 0);
        top_box.pack_end (cancel_button, false, false, 0);

        var mode_button = new Granite.Widgets.ModeButton ();
        mode_button.get_style_context ().add_class ("quick-find-modebutton");
        mode_button.margin = 6;
        mode_button.valign = Gtk.Align.CENTER;
        mode_button.append_text (_("Library"));
        mode_button.append_text (_("Radios"));
        //mode_button.append_text (_("Podcasts"));
        mode_button.selected = 0;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.height_request = 450;
        main_box.width_request = 325;
        main_box.get_style_context ().add_class ("quick-find");
        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (mode_button, false, false, 0);

        add (main_box);

        cancel_button.clicked.connect (() => {
            reveal = false;
        });
    }
}