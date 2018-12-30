public class Services.Signals : GLib.Object {
    public signal void play_track ();
    public signal void pause_track ();

    public signal void ready_file ();

    public Signals () {

    }
}
