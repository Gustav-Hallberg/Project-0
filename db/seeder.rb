require 'sqlite3'

class Seeder 

def self.seed!
    drop_tables
    create_tables
    seed_tables
end

def self.db
    if @db == nil
        @db = SQLite3::Database.new('./db/db.sqlite')
        @db.results_as_hash = true
    end
    return @db
end

def self.drop_tables
    db.execute('DROP TABLE IF EXISTS elever')
end

def self.create_tables

    db.execute('CREATE TABLE elever(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INT NOT NULL,
        description TEXT
    )')

end

def self.seed_tables

    elever = [
        {name: 'Gustav', age: 19, description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation'},
        {name: 'Kevin', age: 19, description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation'}
    ]

    elever.each do | elev |
        db.execute('INSERT INTO elever (name, age, description) VALUES (?,?,?)', [elev[:name], elev[:age], elev[:description]])
    end

end

end 