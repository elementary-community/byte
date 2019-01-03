public class Widgets.ActionBar : Gtk.ActionBar {

    public ActionBar () {
        Object (

        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        get_style_context ().add_class ("actionbar");

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_button.margin = 3;
        add_button.can_focus = false;

        var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.MENU);
        remove_button.margin = 3;
        remove_button.can_focus = false;

        var preferences_button = new Gtk.ToggleButton ();
        preferences_button.add (new Gtk.Image.from_icon_name ("preferences-system-symbolic", Gtk.IconSize.MENU));
        preferences_button.tooltip_text = _("Preferences");
        preferences_button.valign = Gtk.Align.CENTER;
        preferences_button.halign = Gtk.Align.CENTER;
        preferences_button.margin = 3;
        preferences_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        pack_start (add_button);
        pack_start (remove_button);
        pack_end (preferences_button);

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
