public class Widgets.Welcome : Gtk.EventBox {
    private Granite.Widgets.Welcome welcome;

    public signal void selected (int index);
    public Welcome () {
        Object (

        );
    }

    construct {
        welcome = new Granite.Widgets.Welcome (_("Playlist is Empty"), _("Add music to start jamming out"));
        welcome.append ("byte-folder-open", _("Add from folder"), _("Pick a folder with your music in it"));
        welcome.append ("byte-drag-music", _("Drag n' Drop"), _("Toss your music here"));
        welcome.get_style_context ().add_class ("w-round");

        add (welcome);

        welcome.activated.connect ((index) => {
            selected (index);
       });
    }
}
