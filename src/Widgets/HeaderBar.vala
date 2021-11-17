public class Widgets.HeaderBar : Hdy.HeaderBar {
    private Gtk.ProgressBar progress_bar;

    public HeaderBar () {
        Object (
            decoration_layout: "close:"
        );
    }

    construct {
        var search_icon = new Gtk.Image ();
        search_icon.gicon = new ThemedIcon ("system-search-symbolic");
        search_icon.pixel_size = 16;

        var search_button = new Gtk.Button () {
            halign = Gtk.Align.END,
            image = search_icon,
            valign = Gtk.Align.CENTER,
            can_focus = false
        };
        search_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        search_button.get_style_context ().add_class ("font-bold");

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        cancel_button.get_style_context ().add_class ("font-bold");

        var search_cancel_stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        search_cancel_stack.add_named (search_button, "search");
        search_cancel_stack.add_named (cancel_button, "cancel");

        var action_label = new Gtk.Label (null) {
            hexpand = true,
            justify = Gtk.Justification.CENTER,
            ellipsize = Pango.EllipsizeMode.END,
        };

        progress_bar = new Gtk.ProgressBar ();
        progress_bar.fraction = 1;

        var action_grid = new Gtk.Grid ();
        action_grid.column_spacing = 6;
        action_grid.row_spacing = 6;
        action_grid.margin_start = 12;
        action_grid.margin_end = 12;
        action_grid.attach (action_label, 0, 0, 1, 1);
        action_grid.attach (progress_bar, 0, 1, 1, 1);

        var title_label = new Gtk.Label (_("Byte"));
        title_label.get_style_context ().add_class ("font-bold");
        title_label.get_style_context ().add_class ("image-button");

        var empty_grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        empty_grid.add (title_label);

        var search_entry = new Gtk.SearchEntry () {
            hexpand = true
        };
        search_entry.get_style_context ().add_class ("border-radius");

        var search_grid = new Gtk.Grid () {
            hexpand = true,
            column_spacing = 6
        };
        search_grid.add (search_entry);

        var stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.halign = Gtk.Align.CENTER;
        stack.add_named (empty_grid, "empty");
        stack.add_named (action_grid, "action");
        stack.add_named (search_grid, "search");
        
        set_custom_title (stack);
        pack_end (search_cancel_stack);
        show_all ();

        Byte.library_manager.sync_started.connect (() => {
            stack.visible_child_name = "action";
        });

        Byte.library_manager.sync_finished.connect (() => {
            stack.visible_child_name = "empty";
        });

        Byte.library_manager.sync_progress.connect ((fraction) => {
            progress_bar.fraction = fraction;
        });

        search_button.clicked.connect (() => {
            search_cancel_stack.visible_child_name = "cancel";
            stack.visible_child_name = "search";
            search_entry.grab_focus ();
        });

        cancel_button.clicked.connect (() => {
            search_cancel_stack.visible_child_name = "search";
            stack.visible_child_name = "empty";
            search_entry.text = "";
        });

        search_entry.focus_out_event.connect (() => {
            search_cancel_stack.visible_child_name = "search";
            stack.visible_child_name = "empty";
            search_entry.text = "";
            return false;
        });
    }
}