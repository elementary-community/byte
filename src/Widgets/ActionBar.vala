public class Widgets.ActionBar : Gtk.EventBox {

    public ActionBar () {
        Object (

        );
    }

    construct {
        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_button.margin = 3;
        add_button.can_focus = false;

        var info_label = new Gtk.Label (null); //"31 Tracks, 1 Hour and 32 Minutes"
        info_label.label = _("%i Tracks".printf (Application.database.get_tracks_number ()));
        
        var menu_button = new Gtk.ToggleButton ();
        menu_button.add (new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.MENU));
        menu_button.tooltip_text = _("Preferences");
        menu_button.valign = Gtk.Align.CENTER;
        menu_button.halign = Gtk.Align.CENTER;
        menu_button.margin = 3;
        menu_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var menu_popover = new Widgets.Popovers.Menu (menu_button);

        menu_button.toggled.connect (() => {
            if (menu_button.active) {
                menu_popover.show_all ();
            }
        });
  
        menu_popover.closed.connect (() => {
            menu_button.active = false;
        });

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.get_style_context ().add_class ("actionbar");

        action_bar.pack_start (add_button);
        action_bar.set_center_widget (info_label);
        action_bar.pack_end (menu_button);

        var eventbox = new Gtk.EventBox ();
        eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        eventbox.add (action_bar);

        add (eventbox);

        eventbox.enter_notify_event.connect ((event) => {
            return false;
        });

        eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            return false;
        });

        add_button.clicked.connect (() => {
            var chooser = new Gtk.FileChooserDialog (
    				_("Select your favorite files"), null, Gtk.FileChooserAction.OPEN,
    				_("Cancel"),
    				Gtk.ResponseType.CANCEL,
    				_("Open"),
    				Gtk.ResponseType.ACCEPT);

    		chooser.select_multiple = true;

    		Gtk.FileFilter filter = new Gtk.FileFilter ();
    		filter.set_filter_name ("Audio");
    		filter.add_pattern ("*.mp3");
    		filter.add_pattern ("*.flac");
    		chooser.add_filter (filter);

    		if (chooser.run () == Gtk.ResponseType.ACCEPT) {
    			SList<string> uris = chooser.get_uris ();
    			foreach (unowned string uri in uris) {
                    stdout.printf (uri + "\n");
                    Application.utils.found_music_file (uri);
    			}
    		}

    		chooser.close ();
        });
    }
}
