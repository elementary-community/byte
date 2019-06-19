public class Widgets.TrackAlbumRow : Gtk.ListBoxRow {
    public Objects.Track track { get; construct; }

    private Gtk.Label track_label;
    private Gtk.Label title_label;
    private Gtk.Label duration_label;

    public TrackAlbumRow (Objects.Track track) {
        Object (
            track: track
        );
    }

    construct {
        get_style_context ().add_class ("track-row");
        
        track_label = new Gtk.Label ("%i".printf (track.track));
        track_label.halign = Gtk.Align.START;

        title_label = new Gtk.Label (track.title);
        //title_label.margin_start = 24;
        //title_label.get_style_context ().add_class ("font-bold");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.max_width_chars = 45;
        title_label.halign = Gtk.Align.START;

        duration_label = new Gtk.Label (Byte.utils.get_formated_duration (track.duration));
        //duration_label.halign = Gtk.Align.END;
        //duration_label.hexpand = true;

        var options_button = new Gtk.ToggleButton ();
        //options_button.valign = Gtk.Align.CENTER;
        //options_button.halign = Gtk.Align.END;
        //options_button.hexpand = true;
        options_button.can_focus = false;
        options_button.add (new Gtk.Image.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.MENU));
        options_button.tooltip_text = _("Options");
        options_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        options_button.get_style_context ().add_class ("options-button");
        options_button.get_style_context ().remove_class ("button");

        var options_stack = new Gtk.Stack ();
        options_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        options_stack.add_named (duration_label, "duration_label");
        options_stack.add_named (options_button, "options_button");

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.hexpand = true;
        main_box.margin = 6;
        main_box.margin_end = 12;
        //main_box.pack_start (track_label, false, false, 0);
        main_box.pack_start (title_label, false, false, 0);
        main_box.pack_end (options_stack, false, false, 0);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 6;

        var grid = new Gtk.Grid ();
        grid.hexpand = true;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (main_box);
        grid.add (separator);

        var eventbox = new Gtk.EventBox ();
        eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        eventbox.add (grid);

        add (eventbox);
        
        Byte.player.current_track_changed.connect ((current_track) => {
            if (track.id == current_track.id) {
                //playing_revealer.reveal_child = true;
            } else {
                //playing_revealer.reveal_child = false;
            }
        });

        eventbox.enter_notify_event.connect ((event) => {
            options_stack.visible_child_name = "options_button";

            return false;
        });

        eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            options_stack.visible_child_name = "duration_label";

            return false;
        });
    }
}
