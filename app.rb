class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    get "/fruits" do
        @fruits = db.execute("SELECT * FROM fruits")
        p @fruits
        erb :"fruits/index"
    end

    get "/fruits/new" do
        erb :"fruits/new"
    end
    
    # Show info about 1 specific fruit
    get "/fruits/:id" do | id |
        sql = "SELECT * FROM fruits WHERE id=?"
        @fruit = db.execute(sql, id).first
        erb :"fruits/show"
    end

    # Adds new fruit to db
    post "/fruits" do
        name = params["fruit_name"]
        description = params["fruit_description"]

        sql = "INSERT INTO fruits (name, description) VALUES(?,?)"
        db.execute(sql, [name, description])

        redirect("/fruits")
    end

    # Remove fruits in db
    post '/fruits/:id/delete' do | id |
        p id
        sql = "DELETE FROM fruits WHERE id=?"
        db.execute(sql, id)

        redirect("/fruits")
    end

    # Updates fruit in db
    get '/fruits/:id/edit' do | id |
        sql = "SELECT * FROM fruits WHERE id=?"
        @fruit = db.execute(sql, id).first
        erb :"fruits/update"
    end

    post "/fruits/:id/update" do | id |
        name = params["fruit_name"]
        description = params["fruit_description"]

        sql = "UPDATE fruits SET name=?, description=? WHERE id=?"
        db.execute(sql, [name, description, id])

        redirect("/fruits/#{id}")
    end
end