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
        @elever = db.execute("SELECT * FROM elever ORDER BY class, name DESC")
        erb :"elever/index"
    end

    # Shows page to make new elev
    get "/elever/new" do
        erb :"elever/new"
    end

    # Show elever game for all classes
    get "/elever/game" do 
        sql = "SELECT * FROM elever"
        @result = db.execute(sql).to_json
        p @result
        erb :"elever/game"
    end

    get "/elever/game2" do
        sql = "SELECT * FROM elever"
        @result = db.execute(sql).to_json
        p @result
        erb :"elever/game2"        
    end

    # Show elever game for a spesific class
    get "/elever/game/:class" do | selectedClass | 
        sql = "SELECT * FROM elever WHERE class=?"
        
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

        p search.capitalize()

        if(@elev == nil)
            p "We shouldnt be here"

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
    post "/elever/new" do
        image_save_dir = "/images/upload/"

        name = params["elev_name"]
        description = params["elev_description"]
        age = params["elev_age"]
        elev_class = params["elev_class"]
        elev_image = params["elev_image"]

        # Checks if file exists
        if(!File.exists?("public"+image_save_dir+elev_image["filename"]))

            # Creates a new file at directory and copies tempfile data to new file
            File.open("public"+image_save_dir+elev_image["filename"], "w") do | f |
                File.open(elev_image["tempfile"], "r") do | input |
                    IO.copy_stream(input, f)
                end
            end
            sql = "INSERT INTO elever (name, age, description, class, image_url) VALUES(?,?,?,?,?)"
            
            db.execute(sql, [name, age, description, elev_class, image_save_dir+elev_image["filename"]])
        end


        redirect("/elever")
    end

    post "/elever/new/bulk" do
        image_save_dir = "/images/upload/"
        Zip::File.open(params["zipfile"]["tempfile"]) do |zipfile|
            zipfile.each do |file|

                # Get title info from pictures
                # Removes weird irrelevant files
                if(file.name.include?("__MACOSX"))
                    next
                end

                # Removes non-images
                if(!file.name.end_with?(".jpeg") && !file.name.end_with?(".png") && !file.name.end_with?(".jpg"))
                    next
                end

                # Removes the prefix that is the zipfiles name
                file.name = file.name.delete_prefix(params["zipfile"]["filename"].delete_suffix(".zip"))
                
                
                # Removes file extention
                file.name = file.name[1..-1]

                # Encodes to UTF-8
                file.name = file.name.force_encoding("UTF-8")

                info_array = file.name.split("_")

                info_array[3] = info_array[3].split(".")[0]

                info_array.append(image_save_dir+file.name)

                elev_sql = "INSERT INTO elever (name, age, class, description, image_url) VALUES(?,?,?,?,?)"

                db.execute(elev_sql, info_array)

                # Store image
                file.extract("public"+image_save_dir+file.name)
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
