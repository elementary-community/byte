public class Widgets.Queue : Gtk.Revealer {
    private Widgets.Cover image_cover;
    private Gtk.Button view_button;

    private Gtk.ListBox queue_listbox;
    private Gee.ArrayList<Objects.Track?> items;
    private Gtk.Revealer loading_revealer;
    private int item_index;
    private int item_max;
    public Queue () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        valign = Gtk.Align.END;
        halign = Gtk.Align.CENTER;
        reveal_child = false;
    }

    construct {
        items = new Gee.ArrayList<Objects.Track?> ();

        image_cover = new Widgets.Cover.with_default_icon (24);

        var next_track_label = new Gtk.Label ("<small>%s</small>".printf (_("Queue")));
        next_track_label.valign = Gtk.Align.END;
        next_track_label.halign = Gtk.Align.START;
        next_track_label.use_markup = true;
        next_track_label.get_style_context ().add_class ("search-title");
        next_track_label.get_style_context ().add_class ("font-bold");

        var next_track_name = new Gtk.Label (null);
        next_track_name.valign = Gtk.Align.START;
        next_track_name.halign = Gtk.Align.START;
        next_track_name.use_markup = true;
        next_track_name.max_width_chars = 25;
        next_track_name.ellipsize = Pango.EllipsizeMode.END;

        var next_track_grid = new Gtk.Grid ();
        next_track_grid.column_spacing = 3;
        next_track_grid.attach (image_cover, 0, 0, 1, 2);
        next_track_grid.attach (next_track_label, 1, 0, 1, 1);
        next_track_grid.attach (next_track_name, 1, 1, 1, 1);

        var view_button = new Gtk.Button.with_label (_("View all"));
        view_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        view_button.get_style_context ().add_class ("button-color");
        view_button.can_focus = false;
        view_button.valign = Gtk.Align.CENTER;

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.pack_start (next_track_grid, false, false, 0);
        top_box.pack_end (view_button, false, false, 0);

        var top_revealer = new Gtk.Revealer ();
        top_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        top_revealer.expand = true;
        top_revealer.add (top_box);
        top_revealer.reveal_child = true;

        var title_label = new Gtk.Label ("Queue");
        title_label.halign = Gtk.Align.START;

        var hide_button = new Gtk.Button.with_label (_("Hide"));
        hide_button.can_focus = false;
        hide_button.valign = Gtk.Align.CENTER;
        hide_button.valign = Gtk.Align.CENTER;
        hide_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        title_box.get_style_context ().add_class ("queue-title");
        title_box.pack_start (title_label, false, false, 0);
        title_box.pack_end (hide_button, false, false, 0);

        var title_revealer = new Gtk.Revealer ();
        title_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        title_revealer.expand = true;
        title_revealer.add (title_box);
        title_revealer.reveal_child = false;

        queue_listbox = new Gtk.ListBox (); 
        queue_listbox.expand = true;

        var queue_scrolled = new Gtk.ScrolledWindow (null, null);
        queue_scrolled.margin_bottom = 6;
        queue_scrolled.margin_top = 3;
        queue_scrolled.height_request = 275;
        queue_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        queue_scrolled.expand = true;
        queue_scrolled.add (queue_listbox);

        var tracks_revealer = new Gtk.Revealer ();
        tracks_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        tracks_revealer.expand = true;
        tracks_revealer.add (queue_scrolled);
        tracks_revealer.reveal_child = false;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.margin_bottom = 6;
        main_box.width_request = 325;
        main_box.get_style_context ().add_class ("queue");
        main_box.pack_start (title_revealer, true, false, 0);
        main_box.pack_start (top_revealer, false, false, 0);
        main_box.pack_start (tracks_revealer, true, true, 0);

        add (main_box);

        Byte.utils.play_items.connect ((_items) => {
            queue_listbox.foreach ((widget) => {
                widget.destroy (); 
            });

            items = new Gee.ArrayList<Objects.Track?> ();
            items = _items;

            item_index = 0;
            item_max = 100;

            if (item_max > items.size) {
                item_max = items.size;
            }
            
            reveal_child = true;
            Byte.player.set_track (items [0]);
            
            add_all_items (items);
        });

        Byte.player.current_track_changed.connect ((track) => {
            queue_listbox.set_filter_func ((row) => {
                var item = row as Widgets.TrackRow;
                if (track.id == item.track.id) {
                    queue_listbox.select_row (row);
                }
                
                return true;
            });

            var next_track = Byte.utils.get_next_track (track);

            if (next_track != null) {
                next_track_name.label = next_track.title;
                next_track_grid.tooltip_text = _("%s by %s".printf (next_track.title, next_track.artist_name));
                
                var cover_path = GLib.Path.build_filename (Byte.utils.COVER_FOLDER, ("album-%i.jpg").printf (next_track.album_id));
                image_cover.pixbuf = new Gdk.Pixbuf.from_file_at_size (cover_path, 27, 27);
            } else {
                next_track_name.label = _("It's over");
            }
        });

        queue_scrolled.edge_reached.connect((pos)=> {
            if (pos == Gtk.PositionType.BOTTOM) {
                
                item_index = item_max;
                item_max = item_max + 100;

                if (item_max > items.size) {
                    item_max = items.size;
                }

                print ("all: %i\n".printf (items.size));

                add_all_items (items);
            }
        });

        hide_button.clicked.connect (() => {
            title_revealer.reveal_child = false;
            top_revealer.reveal_child = true;
            tracks_revealer.reveal_child = false;
        });

        view_button.clicked.connect (() => {
            title_revealer.reveal_child = true;
            tracks_revealer.reveal_child = true;
            top_revealer.reveal_child = false;
        });
    }

    private void add_all_items (Gee.ArrayList<Objects.Track?> items) {
        for (int i = item_index; i < item_max; i++) {
            var row = new Widgets.TrackRow (items [i]);

            queue_listbox.add (row);
            queue_listbox.show_all ();
        }
    }
}