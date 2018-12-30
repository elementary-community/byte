public class MainWindow : Gtk.Window {
    public weak Application app { get; construct; }
    private Widgets.HeaderBar headerbar;
    private Widgets.ActionBar actionbar;

    private Views.Welcome welcome_view;
    private Views.Main main_view;

    private Gtk.Stack main_stack;

    public MainWindow (Application application) {
        Object (
            application: application,
            app: application,
            icon_name: "com.github.alainm23.byte",
            title: _("Byte"),
            height_request: 750,
            width_request: 575
        );
    }

    construct {
        headerbar = new Widgets.HeaderBar (this);
        headerbar.show_close_button = true;

        set_titlebar (headerbar);

        welcome_view = new Views.Welcome ();
        main_view = new Views.Main ();

        main_stack = new Gtk.Stack ();
        main_stack.expand = true;
        main_stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

        main_stack.add_named (welcome_view, "welcome_view");
        main_stack.add_named (main_view, "main_view");

        actionbar = new Widgets.ActionBar ();

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (main_stack, true, true, 0);
        main_box.pack_end (actionbar, false, false, 0);

        add (main_box);

        welcome_view.selected.connect ((index) => {
            if (index == 0) {
                main_stack.visible_child_name = "main_view";
            } else {
                var file = new Gtk.FileChooserDialog ("Seleccionar una musica en formato MP3", null, Gtk.FileChooserAction.OPEN);
		        file.add_button (Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
		        file.add_button (Gtk.Stock.OK, Gtk.ResponseType.ACCEPT);

                if (file.run () == Gtk.ResponseType.ACCEPT) {
			        File archi = file.get_file (); //obtiene el archivo en un puntero 'archi'
			        //info_view.pat.set_text (archi.get_uri ()); //obtiene la ruta del archivo y la guarda en PAT
                    //info = info_view.discover.discover_uri(archi.get_uri ());

                    Application.stream_player.ready_file (archi.get_uri ());

                    Application.signals.ready_file ();

                    main_stack.visible_child_name = "main_view";
		        }

                file.destroy ();
            }
        });
    }
}
