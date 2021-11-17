/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Services.Database : GLib.Object {
    private Sqlite.Database db;
    private string db_path;
    private string errormsg;
    
    public signal void added_new_artist (Objects.Artist artist);
    public signal void added_new_album (Objects.Album album);
    public signal void adden_new_track (Objects.Track track);

    public signal void opened ();
    public signal void reset ();

    GLib.List<Objects.Artist> _artists = null;
    public GLib.List<Objects.Artist> artists {
        get {
            if (_artists == null) {
                _artists = get_artist_collection ();
            }
            return _artists;
        }
    }

    public void open_database () {
        db_path = Environment.get_user_data_dir () + "/com.github.alainm23.byte/database.db";

        create_tables ();
        patch_database ();
        opened ();
    }

    public void patch_database () {

    }

    private void create_tables () {
        Sqlite.Database.open (db_path, out db);
        string sql;

        sql = """CREATE TABLE IF NOT EXISTS artists (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            name        TEXT        NOT NULL,
            date_added  TEXT        NOT NULL,
            CONSTRAINT unique_artist UNIQUE (name)
            );""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """CREATE TABLE IF NOT EXISTS albums (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            artist_id   INT         NOT NULL,
            title       TEXT        NOT NULL,
            year        INT         NULL,
            date_added  TEXT        NOT NULL,
            CONSTRAINT unique_album UNIQUE (artist_id, title),
            FOREIGN KEY (artist_id) REFERENCES artists (ID)
                ON DELETE CASCADE
            );""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """CREATE TABLE IF NOT EXISTS tracks (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            album_id    INT         NOT NULL,
            path        TEXT        NOT NULL,
            title       TEXT        NOT NULL,
            genre       TEXT        NULL,
            track       INT         NOT NULL,
            disc        INT         NOT NULL,
            duration    INT         NOT NULL,
            date_added  TEXT        NOT NULL,
            CONSTRAINT unique_track UNIQUE (path),
            FOREIGN KEY (album_id) REFERENCES albums (ID)
                ON DELETE CASCADE
            );""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """CREATE TABLE IF NOT EXISTS blacklist (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            path        TEXT        NOT NULL
            )""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """CREATE TABLE IF NOT EXISTS playlists (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            title       TEXT        NOT NULL,
            date_added  TEXT        NOT NULL,
            CONSTRAINT unique_title UNIQUE (title)
            );""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """CREATE TABLE IF NOT EXISTS playlist_tracks (
            ID          INTEGER     PRIMARY KEY AUTOINCREMENT,
            playlist_id INT         NOT NULL,
            track_id    INT         NOT NULL,
            sort        INT         NOT NULL,
            date_added  TEXT        NOT NULL,
            CONSTRAINT unique_track UNIQUE (playlist_id, track_id),
            FOREIGN KEY (track_id) REFERENCES tracks (ID)
                ON DELETE CASCADE,
            FOREIGN KEY (playlist_id) REFERENCES playlists (ID)
                ON DELETE CASCADE
            );""";

        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }

        sql = """PRAGMA foreign_keys = ON;""";
        if (db.exec (sql, null, out errormsg) != Sqlite.OK) {
            warning (errormsg);
        }
    }

    // ARTIST REGION
    public Objects.Artist _fill_artist (Sqlite.Statement stmt) {
        Objects.Artist return_value = new Objects.Artist ();
        return_value.ID = stmt.column_int (0);
        return_value.name = stmt.column_text (1);
        return return_value;
    }

    public Objects.Artist? get_artist_by_album_id (int id) {
        Objects.Artist? return_value = null;
        Sqlite.Statement stmt;
        string sql = """
            SELECT artist_id
            FROM albums
            WHERE id=$ALBUMS_ID
            ;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$ALBUMS_ID", id);

        if (stmt.step () == Sqlite.ROW) {
            var artist_id = stmt.column_int (0);
            foreach (var artist in artists) {
                if (artist.ID == artist_id) {
                    return artist;
                }
            }
        }
        stmt.reset ();
        return return_value;
    }
    
    public GLib.List<Objects.Artist> get_artist_collection () {
        GLib.List<Objects.Artist> return_value = new GLib.List<Objects.Artist> ();

        Sqlite.Statement stmt;
        string sql = """
            SELECT id, name FROM artists ORDER BY name;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);

        while (stmt.step () == Sqlite.ROW) {
            return_value.append (_fill_artist (stmt));
        }
        stmt.reset ();
        return return_value;
    }

    public Objects.Artist insert_artist_if_not_exists (Objects.Artist new_artist) {
        Objects.Artist? return_value = null;
        lock (_artists) {
            foreach (var artist in artists) {
                if (artist.name == new_artist.name) {
                    return_value = artist;
                    break;
                }
            }
            if (return_value == null) {
                insert_artist (new_artist);
                return_value = new_artist;
            }
            return return_value;
        }
    }

    public void insert_artist (Objects.Artist artist) {
        Sqlite.Statement stmt;
        string sql = """
            INSERT OR IGNORE INTO artists (name, date_added) VALUES ($NAME, $DATE_ADDED);
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_str (stmt, sql, "$NAME", artist.name);
        set_parameter_str (stmt, sql, "$DATE_ADDED", artist.date_added);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();

        sql = """
            SELECT id FROM artists WHERE name=$NAME;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_str (stmt, sql, "$NAME", artist.name);

        if (stmt.step () == Sqlite.ROW) {
            artist.ID = stmt.column_int (0);
            stdout.printf ("Artist ID: %d - %s\n", artist.ID, artist.name);
            _artists.append (artist);
            added_new_artist (artist);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();
    }

    // ALBUM REGION
    public GLib.List<Objects.Album> get_album_collection (Objects.Artist artist) {
        GLib.List<Objects.Album> return_value = new GLib.List<Objects.Album> ();
        Sqlite.Statement stmt;

        string sql = """
            SELECT id, title, year FROM albums WHERE artist_id=$ARTIST_ID ORDER BY year;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$ARTIST_ID", artist.ID);

        while (stmt.step () == Sqlite.ROW) {
            return_value.append (_fill_album (stmt, artist));
        }
        stmt.reset ();
        return return_value;
    }

    private Objects.Album _fill_album (Sqlite.Statement stmt, Objects.Artist? artist) {
        Objects.Album return_value = new Objects.Album (artist);
        return_value.ID = stmt.column_int (0);
        return_value.title = stmt.column_text (1);
        return_value.year = stmt.column_int (2);
        return return_value;
    }

    public void insert_album (Objects.Album album) {
        Sqlite.Statement stmt;

        string sql = """
            INSERT OR IGNORE INTO albums (artist_id, title, year, date_added) VALUES ($ARTIST_ID, $TITLE, $YEAR, $DATE_ADDED);
        """;
        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$ARTIST_ID", album.artist.ID);
        set_parameter_str (stmt, sql, "$TITLE", album.title);
        set_parameter_int (stmt, sql, "$YEAR", album.year);
        set_parameter_str (stmt, sql, "$DATE_ADDED", album.date_added);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();

        sql = """
            SELECT id FROM albums WHERE artist_id=$ARTIST_ID AND title=$TITLE;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$ARTIST_ID", album.artist.ID);
        set_parameter_str (stmt, sql, "$TITLE", album.title);

        if (stmt.step () == Sqlite.ROW) {
            album.ID = stmt.column_int (0);
            added_new_album (album);
            stdout.printf ("Album ID: %d - %s\n", album.ID, album.title);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();
    }

    public Objects.Album? get_album_by_track_id (int id) {
        Objects.Album? return_value = null;
        Sqlite.Statement stmt;

        string sql = """
            SELECT albums.id, albums.title, year
            FROM tracks LEFT JOIN albums
            ON tracks.album_id=albums.id
            WHERE tracks.id=$TRACK_ID;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$TRACK_ID", id);

        if (stmt.step () == Sqlite.ROW) {
            return_value = _fill_album (stmt, null);
        }
        stmt.reset ();
        return return_value;
    }

    // TRACK REGION
    public GLib.List<Objects.Track> get_track_collection (Objects.TracksContainer container) {
        GLib.List<Objects.Track> return_value = new GLib.List<Objects.Track> ();
        Sqlite.Statement stmt;

        string sql;

        if (container is Objects.Album) {
            sql = """
                SELECT id, title, genre, track, disc, duration, path
                FROM tracks
                WHERE album_id=$CONTAINER_ID
                ORDER BY disc, track, title;
            """;
        } else {
            sql = """
                SELECT tracks.id, title, genre, sort, disc, duration, path
                FROM playlist_tracks LEFT JOIN tracks
                ON playlist_tracks.track_id = tracks.id
                WHERE playlist_id=$CONTAINER_ID
                ORDER BY sort;
            """;
        }

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$CONTAINER_ID", container.ID);

        while (stmt.step () == Sqlite.ROW) {
            return_value.append (_fill_track (stmt, container));
        }
        stmt.reset ();
        return return_value;
    }

    public GLib.List<Objects.Track> get_last_added_track_collection () {
        GLib.List<Objects.Track> return_value = new GLib.List<Objects.Track> ();
        Sqlite.Statement stmt;

        string sql;

        sql = """
            SELECT id, title, genre, track, disc, duration, path
            FROM tracks
            ORDER BY date_added DESC LIMIT 6;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);

        while (stmt.step () == Sqlite.ROW) {
            return_value.append (_fill_track (stmt, null));
        }
        stmt.reset ();
        return return_value;
    }

    public void insert_track (Objects.Track track) {
        Sqlite.Statement stmt;

        print ("album_id: %i\n".printf (track.album.ID));
        print ("title: %s\n".printf (track.title));
        print ("genre: %s\n".printf (track.genre));
        print ("path: %s\n".printf (track.uri));
        print ("date_added: %s\n".printf (track.date_added));
        
        string sql = """
            INSERT OR IGNORE INTO tracks (album_id, title, genre, track, disc, duration, path, date_added) VALUES ($ALBUM_ID, $TITLE, $GENRE, $TRACK, $DISC, $DURATION, $URI, $DATE_ADDED);
        """;
        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_int (stmt, sql, "$ALBUM_ID", track.album.ID);
        set_parameter_str (stmt, sql, "$TITLE", track.title);
        set_parameter_str (stmt, sql, "$GENRE", track.genre);
        set_parameter_int (stmt, sql, "$TRACK", track.track);
        set_parameter_int (stmt, sql, "$DISC", track.disc);
        set_parameter_int64 (stmt, sql, "$DURATION", (int64) track.duration);
        set_parameter_str (stmt, sql, "$URI", track.uri);
        set_parameter_str (stmt, sql, "$DATE_ADDED", track.date_added);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();

        sql = """
            SELECT id FROM tracks WHERE path=$URI;
        """;

        db.prepare_v2 (sql, sql.length, out stmt);
        set_parameter_str (stmt, sql, "$URI", track.uri);

        if (stmt.step () == Sqlite.ROW) {
            track.ID = stmt.column_int (0);
            stdout.printf ("Track ID: %d - %s\n", track.ID, track.title);
            adden_new_track (track);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();
    }

    private Objects.Track _fill_track (Sqlite.Statement stmt, Objects.TracksContainer? container) {
        Objects.Track return_value = new Objects.Track (container);
        return_value.ID = stmt.column_int (0);
        return_value.title = stmt.column_text (1);
        return_value.genre = stmt.column_text (2);
        return_value.track = stmt.column_int (3);
        return_value.disc = stmt.column_int (4);
        return_value.duration = (uint64)stmt.column_int64 (5);
        return_value.uri = stmt.column_text (6);
        if (return_value.uri.has_prefix ("/")) {
            return_value.uri =  "file://" + return_value.uri;
        }
        return return_value;
    }

    public bool is_database_empty () {
        bool returned = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks", -1, out stmt);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            returned = stmt.column_int (0) <= 0;
        }

        
        stmt.reset ();
        return returned;
    }

    // PARAMENTER REGION
    private void set_parameter_int (Sqlite.Statement? stmt, string sql, string par, int val) {
        int par_position = stmt.bind_parameter_index (par);
        stmt.bind_int (par_position, val);
    }

    private void set_parameter_int64 (Sqlite.Statement? stmt, string sql, string par, int64 val) {
        int par_position = stmt.bind_parameter_index (par);
        stmt.bind_int64 (par_position, val);
    }

    private void set_parameter_str (Sqlite.Statement? stmt, string sql, string par, string val) {
        int par_position = stmt.bind_parameter_index (par);
        stmt.bind_text (par_position, val);
    }
}