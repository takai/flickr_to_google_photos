DROP TABLE IF EXISTS albums;

CREATE TABLE albums (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,

  flickr_id   INTEGER,
  google_id   INTEGER,

  title       TEXT NOT NULL       DEFAULT '',
  description TEXT
);

DROP TABLE IF EXISTS photos;

CREATE TABLE photos (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,

  title         TEXT,
  url           TEXT,

  public        INTEGER             DEFAULT 0,
  downloaded_at DATETIME            DEFAULT 0,
  uploaded_at   DATETIME            DEFAULT 0
);
