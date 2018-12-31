public class Services.Database : GLib.Object {
    private Sqlite.Database db;
    private string db_path;

    public Database (bool skip_tables = false) {
        int rc = 0;
        db_path = Environment.get_home_dir () + "/.cache/com.github.alainm23.byte/database.db";

        if (!skip_tables) {
            if (create_tables () != Sqlite.OK) {
                stderr.printf ("Error creating db table: %d, %s\n", rc, db.errmsg ());
                Gtk.main_quit ();
            }
        }

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        Application.signals.discovered_new_item.connect (add_track);
    }

    private int create_tables () {
        int rc;

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        rc = db.exec ("CREATE TABLE IF NOT EXISTS tracks (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "path           VARCHAR," +
            "title          VARCHAR," +
            "artist         VARCHAR," +
            "genre          VARCHAR," +
            "duration       INTEGER," +
            "album          VARCHAR)", null, null);
        debug ("Table trackS created");

        return rc;
    }

    public bool music_file_exists (string uri) {
        bool file_exists = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks WHERE path = ?", -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, uri);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            file_exists = stmt.column_int (0) > 0;
        }

        return file_exists;
    }

    public void add_track (Objects.Track track) {
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("INSERT INTO tracks (path," +
            "title, artist, genre, duration, album)" +
            "VALUES (?, ?, ?, ?, ?, ?)", -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, track.path);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (2, track.title);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (3, track.artist);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (4, track.genre);
        assert (res == Sqlite.OK);

        res = stmt.bind_int64 (5, (int64) track.duration);
        assert (res == Sqlite.OK);

        res = stmt.bind_text(6, track.album);
        assert (res == Sqlite.OK);

        res = stmt.step ();

        if (res == Sqlite.DONE) {
            //on_add_track_signal ();
        }
    }

    public Gee.ArrayList<Objects.Track?> get_all_tracks () {
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT * FROM tracks",
            -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Track?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var track = new Objects.Track ();

            track.id = stmt.column_int (0);
            track.path = stmt.column_text (1);
            track.title = stmt.column_text (2);
            track.artist = stmt.column_text (3);
            track.genre = stmt.column_text (4);
            track.duration = stmt.column_int (5);
            track.album = stmt.column_text (6);

            all.add (track);
        }

        return all;
    }
}
