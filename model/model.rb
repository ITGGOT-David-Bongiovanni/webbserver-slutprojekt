module SlutprojektDB

    DB_PATH = 'db/databas.db'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def get_user_id username
        db = db_connect()
        result = db.execute("SELECT id FROM users WHERE username=?", [username])
        return result.first
    end

    def register_user username,password, telephone
        db = db_connect()
        result = db.execute("INSERT INTO users (username, password, telephone) VALUES (?, ?, ?)", [username,password_digest,telephone])
        return result.first
    end
end