public class Services.Signals : GLib.Object {
    public signal void stream_state_change (string state);
    public signal void play_track ();
    public signal void pause_track ();

    public signal void ready_file ();

    public signal void discovered_new_item (Objects.Track track);
    public signal void discover_started ();
    public signal void discover_finished ();

    public Signals () {

    }
}
