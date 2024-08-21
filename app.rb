class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get "/elever" do
        @elever = db.execute("SELECT * FROM elever")
        erb :"elever/index"
    end

    get "/elever/new" do
        erb :"elever/new"
    end

    get "/elever/game" do
        erb :"elever/game"
    end

    post "/elever/search" do 
        name = params["elev-name"].capitalize();
        sql = "SELECT * FROM elever WHERE name=?"

        @elev = db.execute(sql, name).first

        if(@elev == nil)
            redirect("/elever")
        end

        redirect("/elever/#{@elev["id"]}")
    end
    
    # Show info about 1 specific elev
    get "/elever/:id" do | id |
        sql = "SELECT * FROM elever WHERE id=?"
        @elev = db.execute(sql, id).first
        erb :"elever/show"
    end

    # Adds new elev to db
    post "/elever" do
        name = params["elev_name"]
        description = params["elev_description"]
        age = params["elev_age"]

        sql = "INSERT INTO elever (name, age, description) VALUES(?,?,?)"
        db.execute(sql, [name, age, description])

        redirect("/elever")
    end

    # Remove elever in db
    post '/elever/:id/delete' do | id |
        sql = "DELETE FROM elever WHERE id=?"
        db.execute(sql, id)

        redirect("/elever")
    end

    # Updates elev in db
    get '/elever/:id/edit' do | id |
        sql = "SELECT * FROM elever WHERE id=?"
        @elev = db.execute(sql, id).first
        erb :"elever/update"
    end

    post "/elever/:id/update" do | id |
        name = params["elev_name"]
        description = params["elev_description"]

        sql = "UPDATE elever SET name=?, description=? WHERE id=?"
        db.execute(sql, [name, description, id])

        redirect("/elever/#{id}")
    end
end