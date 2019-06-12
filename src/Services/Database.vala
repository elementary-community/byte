public class Services.Database : GLib.Object {
    private Sqlite.Database db;
    private string db_path;

    public signal void adden_new_track (Objects.Track track);
    public signal void added_new_artist (Objects.Artist artist);
    public signal void added_new_album (Objects.Album album);
    public signal void adden_new_radio (Objects.Radio radio);
    public signal void updated_album_cover (int album_id);
    public Database (bool skip_tables = false) {
        int rc = 0;
        db_path = Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte/database.db";

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
    }

    private int create_tables () {
        int rc;

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        rc = db.exec ("CREATE TABLE IF NOT EXISTS artists (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "name           TEXT    NOT NULL," +
            "CONSTRAINT unique_artist UNIQUE (name))", null, null);
        debug ("Table artists created");

        rc = db.exec ("CREATE TABLE IF NOT EXISTS albums (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "artist_id      INT     NOT NULL," + 
            "year           INT     NOT NULL," +
            "title          TEXT    NOT NULL," +
            "genre          TEXT    NOT NULL," +
            "CONSTRAINT unique_album UNIQUE (artist_id, title)," +
            "FOREIGN KEY (artist_id) REFERENCES artists (id) ON DELETE CASCADE)", null, null);
        debug ("Table albums created");

        rc = db.exec ("CREATE TABLE IF NOT EXISTS tracks (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT," +
            "album_id       INT     NOT NULL," +
            "path           TEXT    NOT NULL," +
            "title          TEXT    NOT NULL," +
            "added_date     TEXT    NOT NULL," +
            "track          INT     NOT NULL," +
            "disc           INT     NOT NULL," +
            "is_favorite    INT     NOT NULL," +
            "duration       INT     NOT NULL," +
            "CONSTRAINT unique_track UNIQUE (path)," +
            "FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE)", null, null);
        debug ("Table trackS created");

        rc = db.exec ("CREATE TABLE IF NOT EXISTS radios (" +
            "id         INTEGER PRIMARY KEY AUTOINCREMENT," +
            "name       TEXT," +
            "url        TEXT," +
            "homepage   TEXT," +
            "tags       TEXT," +
            "favicon    TEXT," +
            "country    TEXT," +
            "state      TEXT)", null, null);
        debug ("Table radios created");

        rc = db.exec ("PRAGMA foreign_keys = ON;");

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

    public bool radio_exists (string url) {
        bool exists = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM radios WHERE url = ?", -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, url);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            exists = stmt.column_int (0) > 0;
        }

        return exists;
    }

    public bool is_database_empty () {
        bool empty = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks", -1, out stmt);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            empty = stmt.column_int (0) <= 0;
        }

        return empty;
    }

    public int get_id_if_artist_exists (Objects.Artist artist) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT COUNT (*) FROM artists WHERE name = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, artist.name);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            if (stmt.column_int (0) > 0) {
                stmt.reset ();

                sql = """
                    SELECT id FROM artists WHERE name = ?;
                """;

                res = db.prepare_v2 (sql, -1, out stmt);
                assert (res == Sqlite.OK);

                res = stmt.bind_text (1, artist.name);
                assert (res == Sqlite.OK);

                if (stmt.step () == Sqlite.ROW) {
                    return stmt.column_int (0);
                } else {
                    warning ("Error: %d: %s", db.errcode (), db.errmsg ());
                    return 0;
                }
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int insert_artist_if_not_exists (Objects.Artist artist) {
        Sqlite.Statement stmt;
        string sql;
        int id;

        id = get_id_if_artist_exists (artist);
        if (id == 0) {
            sql = """
                INSERT OR IGNORE INTO artists (name) VALUES (?);
            """;
            
            int res = db.prepare_v2 (sql, -1, out stmt);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (1, artist.name);
            assert (res == Sqlite.OK);
            
            if (stmt.step () != Sqlite.DONE) {
                warning ("Error: %d: %s", db.errcode (), db.errmsg ());
            }

            artist.id = get_id_if_artist_exists (artist);
            added_new_artist (artist);

            return artist.id;
        } else {
            return id;
        }
    }

    public int get_id_if_album_exists (Objects.Album album) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT COUNT (*) FROM albums WHERE title = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, album.title);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            if (stmt.column_int (0) > 0) {
                stmt.reset ();

                sql = """
                    SELECT id FROM albums WHERE title = ?;
                """;

                res = db.prepare_v2 (sql, -1, out stmt);
                assert (res == Sqlite.OK);

                res = stmt.bind_text (1, album.title);
                assert (res == Sqlite.OK);

                if (stmt.step () == Sqlite.ROW) {
                    return stmt.column_int (0);
                } else {
                    warning ("Error: %d: %s", db.errcode (), db.errmsg ());
                    return 0;
                }
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int insert_album_if_not_exists (Objects.Album album) {
        Sqlite.Statement stmt;
        string sql;
        int id;

        id = get_id_if_album_exists (album);
        if (id == 0) {
            sql = """
                INSERT OR IGNORE INTO albums (artist_id, year, title, genre) VALUES (?, ?, ?, ?);
            """;
            
            int res = db.prepare_v2 (sql, -1, out stmt);
            assert (res == Sqlite.OK);

            res = stmt.bind_int (1, album.artist_id);
            assert (res == Sqlite.OK);

            res = stmt.bind_int (2, album.year);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (3, album.title);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (4, album.genre);
            assert (res == Sqlite.OK);
            
            if (stmt.step () != Sqlite.DONE) {
                warning ("Error: %d: %s", db.errcode (), db.errmsg ());
            }

            album.id = get_id_if_album_exists (album);
            stdout.printf ("Album ID: %d - %s\n", album.id, album.title);

            added_new_album (album);
            return album.id;
        } else {
            return id;
        }
    }

    public void insert_track (Objects.Track track) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            INSERT OR IGNORE INTO tracks (album_id, path, title, track, disc, duration, is_favorite, added_date)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (1, track.album_id);
        assert (res == Sqlite.OK);
        
        res = stmt.bind_text (2, track.path);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (3, track.title);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (4, track.track);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (5, track.disc);
        assert (res == Sqlite.OK);

        res = stmt.bind_int64 (6, (int64) track.duration);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (7, track.is_favorite);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (8, track.added_date);
        assert (res == Sqlite.OK);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();

        sql = """
            SELECT id FROM tracks WHERE path = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, track.path);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            track.id = stmt.column_int (0);
            stdout.printf ("Track ID: %d - %s\n", track.id, track.title);

            Byte.cover_import.import (track);
            
            adden_new_track (track);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();
    }

    public Gee.ArrayList<Objects.Album?> get_all_albums () {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT albums.id, albums.artist_id, albums.year, albums.title, albums.genre, artists.name from albums
            INNER JOIN artists ON artists.id = albums.artist_id ORDER BY albums.title;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Album?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var album = new Objects.Album ();

            album.id = stmt.column_int (0);
            album.artist_id = stmt.column_int (1);
            album.year = stmt.column_int (2);
            album.title = stmt.column_text (3);
            album.genre = stmt.column_text (4);
            album.artist_name = stmt.column_text (5);
            
            all.add (album);
        }

        return all;
    }

    public Gee.ArrayList<Objects.Album?> get_random_albums () {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT albums.id, albums.artist_id, albums.year, albums.title, albums.genre, artists.name from albums
            INNER JOIN artists ON artists.id = albums.artist_id ORDER BY RANDOM() LIMIT 4;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Album?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var album = new Objects.Album ();

            album.id = stmt.column_int (0);
            album.artist_id = stmt.column_int (1);
            album.year = stmt.column_int (2);
            album.title = stmt.column_text (3);
            album.genre = stmt.column_text (4);
            album.artist_name = stmt.column_text (5);
            
            all.add (album);
        }

        return all;
    }

    public Gee.ArrayList<Objects.Track?> get_all_tracks () {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT  tracks.id, tracks.path, tracks.title, tracks.duration, tracks.is_favorite, tracks.added_date, tracks.album_id, albums.title, artists.name FROM tracks 
            INNER JOIN albums ON tracks.album_id = albums.id
            INNER JOIN artists ON albums.artist_id = artists.id ORDER BY tracks.title;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Track?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var track = new Objects.Track ();

            track.id = stmt.column_int (0);
            track.path = stmt.column_text (1);
            track.title = stmt.column_text (2);
            track.duration = stmt.column_int64 (3);
            track.is_favorite = stmt.column_int (4);
            track.added_date = stmt.column_text (5);
            track.album_id = stmt.column_int (6);
            track.album_title = stmt.column_text (7);
            track.artist_name = stmt.column_text (8);
            
            all.add (track);
        }

        return all;
    }

    public Gee.ArrayList<Objects.Track?> get_all_tracks_order_by (int item, bool is_invested) {
        Sqlite.Statement stmt;
        string sql;
        int res;
        string order_mode = "tracks.title";
        string invested_mode = "DESC";
        
        if (item == 0) {
            order_mode = "tracks.title";
        } else if (item == 1) {
            order_mode = "artists.name";
        } else if (item == 2) {
            order_mode = "albums.title";
            //order_mode = "tracks.album_id";
        } else if (item == 3) {
            order_mode = "tracks.added_date";
        }

        if (is_invested == false) {
            invested_mode = "";
        }

        sql = """
            SELECT  tracks.id, tracks.path, tracks.title, tracks.duration, tracks.is_favorite, tracks.added_date, tracks.album_id, albums.title, artists.name FROM tracks 
            INNER JOIN albums ON tracks.album_id = albums.id
            INNER JOIN artists ON albums.artist_id = artists.id ORDER BY %s %s;
        """.printf (order_mode, invested_mode);

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Track?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var track = new Objects.Track ();

            track.id = stmt.column_int (0);
            track.path = stmt.column_text (1);
            track.title = stmt.column_text (2);
            track.duration = stmt.column_int64 (3);
            track.is_favorite = stmt.column_int (4);
            track.added_date = stmt.column_text (5);
            track.album_id = stmt.column_int (6);
            track.album_title = stmt.column_text (7);
            track.artist_name = stmt.column_text (8);
            
            all.add (track);
        }

        return all;
    }

    public Gee.ArrayList<Objects.Artist?> get_all_artists () {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT artists.id, artists.name FROM artists ORDER BY artists.name;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Artist?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var artist = new Objects.Artist ();

            artist.id = stmt.column_int (0);
            artist.name = stmt.column_text (1);
            
            all.add (artist);
        }

        return all;
    }

    public int get_tracks_number () {
        /*
        Sqlite.Statement stmt;
        int c = 0;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks",
            -1, out stmt);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            c = stmt.column_int (0);
        }

        return c;
        */

        return 0;
    }

    public void insert_radio (Objects.Radio radio) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            INSERT OR IGNORE INTO radios (name, url, homepage, tags, favicon, country, state)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, radio.name);
        assert (res == Sqlite.OK);
        
        res = stmt.bind_text (2, radio.url);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (3, radio.homepage);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (4, radio.tags);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (5, radio.favicon);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (6, radio.country);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (7, radio.state);
        assert (res == Sqlite.OK);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();

        sql = """
            SELECT id FROM radios WHERE url = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, radio.url);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            radio.id = stmt.column_int (0);
            stdout.printf ("Radio ID: %d - %s\n", radio.id, radio.name);

            //Byte.cover_import.import (track);
            Byte.utils.download_image ("radio", radio.id, radio.favicon);

            adden_new_radio (radio);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();
    }

    public Gee.ArrayList<Objects.Radio?> get_all_radios () {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT * FROM radios;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Radio?> ();

        while ((res = stmt.step ()) == Sqlite.ROW) {
            var radio = new Objects.Radio ();

            radio.id = stmt.column_int (0);
            radio.name = stmt.column_text (1);
            radio.url = stmt.column_text (2);
            radio.homepage = stmt.column_text (3);
            radio.tags = stmt.column_text (4);
            radio.favicon = stmt.column_text (5);
            radio.country = stmt.column_text (6);
            radio.state = stmt.column_text (7);
            
            all.add (radio);
        }

        return all;
    }
}
