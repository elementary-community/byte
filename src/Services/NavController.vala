public class Services.NavController : GLib.Object {
    public Gtk.Stack? _stack = null;
    public Gtk.Stack? stack {
        set {
            _stack = value;
            go_root ();
        }
        get {
            return _stack;
        }
    }
    private Gee.ArrayList<string> pages;
    private Gee.HashMap<string, bool> pages_loaded;

    construct {
        pages = new Gee.ArrayList<string> ();
        pages_loaded = new Gee.HashMap<string, bool> ();

        go_root ();
    }

    public void go_root () {
        pages.clear ();
        pages.add ("home_view");

        if (stack != null) {
            stack.visible_child_name = "home_view";
        }
    }

    public void push (string page_name) {
        if (pages.add (page_name)) {
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT;
            stack.visible_child_name = page_name;
        }
    }

    public void add_named (Gtk.Widget widget, string name) {
        pages_loaded.set (name, true);
        stack.add_named (widget, name);
    }

    public void pop () {
        stack.transition_type = Gtk.StackTransitionType.SLIDE_RIGHT;

        if (pages.size > 0) {
            pages.remove_at (pages.size - 1);
            stack.visible_child_name = pages [pages.size - 1];
        } else {
            go_root ();
        }
    }

    public bool has_key (string page) {
        return pages_loaded.has_key (page);
    }
}