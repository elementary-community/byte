public class Views.Welcome : Gtk.EventBox {
    public signal void selected (int index);
    construct {
        var welcome = new Granite.Widgets.Welcome (_("Library is Empty"), _("Add music to start jamming out"));
        welcome.append ("document-import", _("Import Music"), _("Import music from a source into your library."));
        welcome.append ("byte-folder-music", _("Change Music Folder"), _("Load music from a folder, a network or an external disk."));

        var content = new Gtk.Grid () {
            expand = true,
            orientation = Gtk.Orientation.VERTICAL
        };
        
        content.add (welcome);

        var scrolled = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vscrollbar_policy = Gtk.PolicyType.NEVER,
            expand = true
        };
        scrolled.add (content);

        add (scrolled);

        welcome.activated.connect ((index) => {
            selected (index);
        });
    }
}