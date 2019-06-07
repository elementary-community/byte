public class Objects.Radio : GLib.Object {
    public int    id       { get; set; default = 0; }
    public string name     { get; set; default = ""; }
    public string url      { get; set; default = ""; }
    public string homepage { get; set; default = ""; }
    public string tags     { get; set; default = ""; }
    public string favicon  { get; set; default = ""; }
    public string country  { get; set; default = ""; }
    public string state    { get; set; default = ""; }
}