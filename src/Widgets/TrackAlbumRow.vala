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
        track_label.get_style_context ().add_class ("label-color-primary");
        track_label.halign = Gtk.Align.START;
        track_label.width_chars = 4;

        var playing_icon = new Gtk.Image ();
        playing_icon.gicon = new ThemedIcon ("audio-volume-high-symbolic");
        playing_icon.get_style_context ().add_class ("label-color-primary");
        playing_icon.pixel_size = 14;

        var playing_stack = new Gtk.Stack ();
        playing_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        playing_stack.add_named (track_label, "track_label");
        playing_stack.add_named (playing_icon, "playing_icon");

        title_label = new Gtk.Label (track.title);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.max_width_chars = 45;
        title_label.halign = Gtk.Align.START;

        duration_label = new Gtk.Label (Byte.utils.get_formated_duration (track.duration));

        var options_button = new Gtk.ToggleButton ();
        options_button.can_focus = false;
        options_button.add (new Gtk.Image.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.MENU));
        options_button.tooltip_text = _("Options");
        options_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        options_button.get_style_context ().add_class ("options-button");
        options_button.get_style_context ().remove_class ("button");

        var options_stack = new Gtk.Stack ();
        options_stack.hexpand = true;
        options_stack.halign = Gtk.Align.END;
        options_stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        options_stack.add_named (duration_label, "duration_label");
        options_stack.add_named (options_button, "options_button");

        var main_grid = new Gtk.Grid ();
        main_grid.hexpand = true;
        main_grid.margin = 6;
        main_grid.margin_end = 12;
        main_grid.margin_start = 0;
        main_grid.column_spacing = 6;
        main_grid.add (playing_stack);
        main_grid.add (title_label);
        main_grid.add (options_stack);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_start = 6;

        var grid = new Gtk.Grid ();
        grid.hexpand = true;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (separator);
        grid.add (main_grid);

        var eventbox = new Gtk.EventBox ();
        eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        eventbox.add (grid);

        add (eventbox);

        if (Byte.player.current_track != null && track.id == Byte.player.current_track.id) {
            title_label.get_style_context ().add_class ("label-color-primary");
            duration_label.get_style_context ().add_class ("label-color-primary");

            Timeout.add (150, () => {
                playing_stack.visible_child_name = "playing_icon";
                return false;
            });
        }

        /*
        Byte.player.current_track_changed.connect ((current_track) => {
            if (track.id == current_track.id) {
                playing_stack.visible_child_name = "playing_icon";
                title_label.get_style_context ().add_class ("label-color-primary");
                duration_label.get_style_context ().add_class ("label-color-primary");
            } else {
                playing_stack.visible_child_name = "track_label";
                title_label.get_style_context ().remove_class ("label-color-primary");
                duration_label.get_style_context ().remove_class ("label-color-primary");
            }
        });
        */
        
        Byte.database.updated_track_favorite.connect ((_track, favorite) => {
            if (track.id == _track.id) {
                track.is_favorite = favorite;
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
