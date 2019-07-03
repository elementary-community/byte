public class Widgets.TrackRow : Gtk.ListBoxRow {
    public Objects.Track track { get; construct; }

    private Gtk.Label primary_label;
    private Gtk.Label secondary_label;
    private Gtk.Label duration_label; 
    private Gtk.Menu menu = null;
    private Widgets.Cover image_cover;
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
        
        image_cover = new Widgets.Cover.from_file (
            GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (track.album_id)), 
            32, "track");
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;

        duration_label = new Gtk.Label (Byte.utils.get_formated_duration (track.duration));
        duration_label.halign = Gtk.Align.END;
        duration_label.hexpand = true;

        var options_button = new Gtk.Button.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.MENU);
        options_button.valign = Gtk.Align.CENTER;
        options_button.halign = Gtk.Align.END;
        options_button.hexpand = true;
        options_button.can_focus = false;
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

        if (Byte.player.current_track != null && track.id == Byte.player.current_track.id) {
            playing_revealer.reveal_child = true;
            main_grid.get_style_context ().add_class ("label-color-primary");
        }

        Byte.player.current_track_changed.connect ((current_track) => {
            if (track.id == current_track.id) {
                playing_revealer.reveal_child = true;
                main_grid.get_style_context ().add_class ("label-color-primary");

                grab_focus ();
            } else {
                playing_revealer.reveal_child = false;
                main_grid.get_style_context ().remove_class ("label-color-primary");
            }
        });

        Byte.database.updated_album_cover.connect ((album_id) => {
            if (album_id == track.album_id) {
                try {
                    image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (
                        GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (album_id)), 
                        32, 
                        32);
                } catch (Error e) {
                    stderr.printf ("Error setting default avatar icon: %s ", e.message);
                }
            }
        });

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

        eventbox.button_press_event.connect ((sender, evt) => {
            if (evt.type == Gdk.EventType.BUTTON_PRESS && evt.button == 3) {
                if (menu == null) {
                    build_context_menu (track);
                }

                menu.popup_at_pointer (null);
                return true;
            }
        });

        options_button.clicked.connect (() => {
            if (menu == null) {
                build_context_menu (track);
            }

            menu.popup_at_pointer (null);
        });
    }

    private void build_context_menu (Objects.Track track) {
        menu = new Gtk.Menu ();
        menu.get_style_context ().add_class ("view");

        var primary_label = new Gtk.Label (track.title);
        primary_label.get_style_context ().add_class ("font-bold");
        primary_label.ellipsize = Pango.EllipsizeMode.END;
        primary_label.max_width_chars = 25;
        primary_label.halign = Gtk.Align.START;

        var secondary_label = new Gtk.Label ("%s - %s".printf (track.artist_name, track.album_title));
        secondary_label.halign = Gtk.Align.START;
        secondary_label.max_width_chars = 25;
        secondary_label.ellipsize = Pango.EllipsizeMode.END;
        
        var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (track.album_id));
        var image_cover = new Gtk.Image ();
        image_cover.halign = Gtk.Align.START;
        image_cover.valign = Gtk.Align.START;
        try {
            image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, 38, 38);
        } catch (Error e) {
            image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size ("/usr/share/com.github.alainm23.byte/track-default-cover.svg", 38, 38);
        }

        var track_grid = new Gtk.Grid ();
        track_grid.width_request = 185;
        track_grid.hexpand = false;
        track_grid.halign = Gtk.Align.START;
        track_grid.valign = Gtk.Align.CENTER;
        track_grid.column_spacing = 6;
        track_grid.attach (image_cover, 0, 0, 1, 2);
        track_grid.attach (primary_label, 1, 0, 1, 1);
        track_grid.attach (secondary_label, 1, 1, 1, 1);

        var track_menu = new Gtk.MenuItem ();
        track_menu.get_style_context ().add_class ("track-options");
        track_menu.get_style_context ().add_class ("css-item");
        track_menu.right_justified = true;
        track_menu.add (track_grid);

        var play_menu = new Widgets.ModelButton (_("Play"), "media-playback-start-symbolic", _("Finalize project"));
        var play_next_menu = new Widgets.ModelButton (_("Play Next"), "document-export-symbolic", _("Export project"));
        var play_last_menu = new Widgets.ModelButton (_("Play Later"), "emblem-shared-symbolic", _("Share project"));
        var add_playlist_menu = new Widgets.ModelButton (_("Add to Playlist"), "zoom-in-symbolic", _("Change project name"));
        var edit_menu = new Widgets.ModelButton (_("Edit"), "edit-symbolic", _("Share project"));
        var favorite_menu = new Widgets.ModelButton (_("Favorite"), "planner-favorite-symbolic", _("Share project"));
        var remove_db_menu = new Widgets.ModelButton (_("Delete from database"), "zoom-out-symbolic", _("Share project"));
        var remove_file_menu = new Widgets.ModelButton (_("Delete from file"), "user-trash-symbolic", _("Share project"));

        menu.add (track_menu);
        menu.add (new Gtk.SeparatorMenuItem ());
        menu.add (play_menu);
        menu.add (play_next_menu);
        menu.add (play_last_menu);
        menu.add (new Gtk.SeparatorMenuItem ());
        menu.add (add_playlist_menu);
        menu.add (edit_menu);
        menu.add (favorite_menu);
        menu.add (new Gtk.SeparatorMenuItem ());
        menu.add (remove_db_menu);
        menu.add (remove_file_menu);

        menu.show_all ();

        track_menu.activate.connect (() => {
            this.activate ();
        });

        play_menu.activate.connect (() => {
            this.activate ();
        });

        play_next_menu.activate.connect (() => {
            Byte.utils.set_next_track (track);
        });

        play_last_menu.activate.connect (() => {
            Byte.utils.set_last_track (track);
        });

        favorite_menu.activate.connect (() => {
            Byte.database.set_track_favorite (track, 1);
        });
    }
}
