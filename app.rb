class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get "/elever" do
        @elever = db.execute("SELECT * FROM elever ORDER BY class, name ASC")
        erb :"elever/index"
    end

    get "/elever/new" do
        erb :"elever/new"
    end

    get "/elever/game" do 
        sql = "SELECT * FROM elever"
        @result = db.execute(sql).to_json
        erb :"elever/game"
    end

    get "/elever/game/:class" do | selectedClass | 
        sql = "SELECT * FROM elever WHERE class=?"
        @result = db.execute(sql, selectedClass).to_json
        erb :"elever/game"
    end

    get "/elever/class/:class" do | selectedClass | 
        sql = "SELECT * FROM elever WHERE class=? ORDER BY name ASC"
        @elever = db.execute(sql, selectedClass)
        @class = selectedClass
        erb :"elever/class"
    end

    post "/elever/search" do 
        search = params["elev-search"];
        sql = "SELECT * FROM elever WHERE name=?"

        @elev = db.execute(sql, search.capitalize()).first

        if(@elev == nil)
            sql = "SELECT * FROM elever WHERE class=?"
            @class = db.execute(sql, search).first
            if(@class != nil)
                redirect("/elever/class/#{search}")
            end

            redirect("/elever")
        end

        redirect("/elever/#{@elev["id"]}")
    end
    
    # Show info about 1 specific elev
    get "/elever/:id" do | id |
        elev_sql = "SELECT * FROM elever WHERE id=?"
        @elev = db.execute(elev_sql, id).first

        elever_count_sql = "SELECT id FROM elever ORDER BY id DESC LIMIT 1"
        @elev_count = db.execute(elever_count_sql)

        @next_page = 1
        @previous_page = 1

        if id.to_i+1 > @elev_count[0]["id"]
            @next_page = 1
        else
            @next_page = id.to_i+1
        end

        if id.to_i-1 <= 0
            @previous_page = @elev_count[0]["id"]
        else
            @previous_page = id.to_i-1
        end

        erb :"elever/show"
    end

    # Adds new elev to db
    post "/elever" do
        name = params["elev_name"]
        description = params["elev_description"]
        age = params["elev_age"]
        elev_class = params["elev_class"]

        sql = "INSERT INTO elever (name, age, description, class) VALUES(?,?,?,?)"
        db.execute(sql, [name, age, description, elev_class])

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