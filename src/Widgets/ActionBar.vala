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

        pack_start (add_button);
        pack_start (remove_button);

        add_button.clicked.connect (() => {
            var file = new Gtk.FileChooserDialog (_("Select a music file"), null, Gtk.FileChooserAction.OPEN);
            file.add_button (Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE);
            file.add_button (Gtk.Stock.OK, Gtk.ResponseType.ACCEPT);

            if (file.run () == Gtk.ResponseType.ACCEPT) {
                File archi = file.get_file (); //obtiene el archivo en un puntero 'archi'
                //info_view.pat.set_text (archi.get_uri ()); //obtiene la ruta del archivo y la guarda en PAT
                //info = info_view.discover.discover_uri(archi.get_uri ());

                Application.stream_player.ready_file (archi.get_uri ());
                Application.signals.ready_file ();

                Application.stream_player.play_file ();
                Application.signals.play_track ();
            }

            file.destroy ();
        });
    }
}
