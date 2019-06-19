public class Widgets.TrackRow : Gtk.ListBoxRow {
    public Objects.Track track { get; construct; }

    private Gtk.Label primary_label;
    private Gtk.Label secondary_label;
    private Gtk.Label duration_label;

    private Widgets.Cover image_cover;

    private string cover_path;
    private bool options_opened = false;
    public TrackRow (Objects.Track track) {
        Object (
            track: track
        );
    }

    construct {
        get_style_context ().add_class ("track-row");
        
        var playing_icon = new Gtk.Image ();
        playing_icon.gicon = new ThemedIcon ("audio-volume-medium-symbolic");
        playing_icon.get_style_context ().add_class ("playing-ani-color");
        playing_icon.pixel_size = 12;

        var playing_revealer = new Gtk.Revealer ();
        playing_revealer.halign = Gtk.Align.CENTER;
        playing_revealer.valign = Gtk.Align.CENTER;
        playing_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        playing_revealer.add (playing_icon);
        playing_revealer.reveal_child = false;

        primary_label = new Gtk.Label (track.title);
        primary_label.get_style_context ().add_class ("font-bold");
        primary_label.ellipsize = Pango.EllipsizeMode.END;
        primary_label.max_width_chars = 45;
        primary_label.halign = Gtk.Align.START;
        primary_label.valign = Gtk.Align.END;

        secondary_label = new Gtk.Label ("%s - %s".printf (track.artist_name, track.album_title));
        secondary_label.halign = Gtk.Align.START;
        secondary_label.valign = Gtk.Align.START;
        secondary_label.max_width_chars = 45;
        secondary_label.ellipsize = Pango.EllipsizeMode.END;
        
        cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (track.album_id));
        image_cover = new Widgets.Cover.from_file (cover_path, 32, "track");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        duration_label = new Gtk.Label (Byte.utils.get_formated_duration (track.duration));
        duration_label.halign = Gtk.Align.END;
        duration_label.hexpand = true;

        var options_button = new Gtk.ToggleButton ();
        options_button.valign = Gtk.Align.CENTER;
        options_button.halign = Gtk.Align.END;
        options_button.hexpand = true;
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

        var overlay = new Gtk.Overlay ();
        overlay.halign = Gtk.Align.START;
        overlay.valign = Gtk.Align.START;
        overlay.add_overlay (playing_revealer);
        overlay.add (image_cover); 

        var options_popover = new Widgets.Popovers.TrackOptions (options_button, track);

        var main_grid = new Gtk.Grid ();
        main_grid.margin_start = 3;
        main_grid.margin_end = 9;
        main_grid.column_spacing = 6;
        main_grid.attach (overlay, 0, 0, 1, 2);
        main_grid.attach (primary_label, 1, 0, 1, 1);
        main_grid.attach (secondary_label, 1, 1, 1, 1);
        main_grid.attach (options_stack, 2, 0, 2, 2);
        
        var eventbox = new Gtk.EventBox ();
        eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        eventbox.add (main_grid);

        add (eventbox);
        
        Byte.player.current_track_changed.connect ((current_track) => {
            if (track.id == current_track.id) {
                playing_revealer.reveal_child = true;
            } else {
                playing_revealer.reveal_child = false;
            }
        });

        eventbox.enter_notify_event.connect ((event) => {
            if (options_opened != true) {
                options_stack.visible_child_name = "options_button";
            }
        
            return false;
        });

        eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }

            if (options_opened != true) {
                options_stack.visible_child_name = "duration_label";
            }

            return false;
        });

        options_button.toggled.connect (() => {
            if (options_button.active) {
                options_opened = true;
                options_popover.show_all ();
            }
        });
        
        options_popover.closed.connect (() => {
            options_opened = false;
            options_button.active = false;
        });
    }
}
