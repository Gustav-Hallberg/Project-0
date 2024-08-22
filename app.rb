class App < Sinatra::Base

    def db
        if @db == nil
            @db = SQLite3::Database.new('./db/db.sqlite')
            @db.results_as_hash = true
        end
        return @db
    end

    # Elever start page
    get "/elever" do
        @elever = db.execute("SELECT * FROM elever ORDER BY class, name ASC")
        erb :"elever/index"
    end

    # Shows page to make new elev
    get "/elever/new" do
        erb :"elever/new"
    end

    # Show elever game for all classes
    get "/elever/game" do 
        sql = "SELECT * FROM elever LEFT JOIN elever_images ON elever.id = elever_images.id"
        @result = db.execute(sql).to_json
        erb :"elever/game"
    end

    # Show elever game for a spesific class
    get "/elever/game/:class" do | selectedClass | 
        sql = "SELECT * FROM elever LEFT JOIN elever_images ON elever.id = elever_images.id WHERE class=?"
        
        @result = db.execute(sql, selectedClass).to_json
        erb :"elever/game"
    end

    # Show elever in a spesific class
    get "/elever/class/:class" do | selectedClass | 
        sql = "SELECT * FROM elever WHERE class=? ORDER BY name ASC"
        @elever = db.execute(sql, selectedClass)
        @class = selectedClass
        erb :"elever/class"
    end

    # Handels user search
    post "/elever/search" do 
        search = params["elev-search"];
        sql = "SELECT * FROM elever WHERE name=?"

        @elev = db.execute(sql, search.capitalize()).first

        if(@elev == nil)
            sql = "SELECT * FROM elever WHERE class=?"
            @class = db.execute(sql, search.upcase).first
            if(@class != nil)
                redirect("/elever/class/#{search.upcase}")
            end

            redirect("/elever")
        end

        redirect("/elever/#{@elev["id"]}")
    end
    
    # Show info about 1 specific elev
    get "/elever/:id" do | id |
        elev_sql = "SELECT * FROM elever LEFT JOIN elever_images ON elever.id = elever_images.id WHERE elever.id=?"
        #elev_sql = "SELECT * FROM elever WHERE id=?"
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
        name = params["name"]
        description = params["description"]
        age = params["age"]
        elev_class = params["className"]
        elev_image = params["image"]

        sql = "INSERT INTO elever (name, age, description, class) VALUES(?,?,?,?)"
        image_sql = "INSERT INTO elever_images (id, image) VALUES(?,?)"
        
        db.execute("BEGIN TRANSACTION")
        
        db.execute(sql, [name, age, description, elev_class])

        image_id = db.last_insert_row_id

        db.execute(image_sql, [image_id, elev_image])
        
        db.execute("COMMIT TRANSACTION")

        redirect("/elever")
    end

    post "/elever/new/bulk" do
        Zip::File.open(params["zipfile"]["tempfile"]) do |zipfile|
            zipfile.each do |file|

                # Removes weird irrelevant files
                if(file.name.include?("__MACOSX"))
                    next
                end

                # Removes non-images
                if(!file.name.end_with?(".jpeg") && !file.name.end_with?(".png") && !file.name.end_with?(".jpg"))
                    next
                end

                file.name = file.name.delete_prefix(params["zipfile"]["filename"].delete_suffix(".zip"))
                file.name = file.name[1..file.name.index(".")-1]
                
                info_array = []

                info_array = file.name.split("_")

                p info_array
            end
        end
    end

    # Remove elever in db
    post '/elever/:id/delete' do | id |
        sql = "DELETE FROM elever WHERE id=?"
        db.execute(sql, id)

        redirect("/elever")
    end

    # Gives page to update elev in db
    get '/elever/:id/edit' do | id |
        sql = "SELECT * FROM elever WHERE id=?"
        @elev = db.execute(sql, id).first
        erb :"elever/update"
    end

    # Updates elev in db
    post "/elever/:id/update" do | id |
        name = params["elev_name"]
        description = params["elev_description"]

        sql = "UPDATE elever SET name=?, description=? WHERE id=?"
        db.execute(sql, [name, description, id])

        redirect("/elever/#{id}")
    end
end