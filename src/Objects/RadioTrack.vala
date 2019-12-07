public class Objects.RadioTrack : GLib.Object {
    public int id       { get; set; default = 0; }
    public int radio_id     { get; set; default = 0; }
    public string title      { get; set; default = ""; }
    public string date_added { get; set; default = ""; }
}