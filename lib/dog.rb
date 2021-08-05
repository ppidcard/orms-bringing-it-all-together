class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    end

    def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
    end

    def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
    end

    def save
    if self.id
        self.update
    else
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
    end
    self
    end

    def self.create(ha_sh)
        dog = Dog.new(name:ha_sh[:name], breed:ha_sh[:breed])
        dog.save
        dog
    end

    def self.new_from_db(row)
    dog = Dog.new(id:row[0], name:row[1], breed:row[2])
    end

    def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        res = DB[:conn].execute(sql, id)[0]
        dog = Dog.new(id:res[0], name:res[1], breed:res[2])
    end

    def self.find_or_create_by(name:, breed:)
        res = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !res.empty?
            dog = res[0]
            dob_ob = Dog.new(id:dog[0], name:dog[1], breed:dog[2])
        else
            
                dob_ob = Dog.create(name:name, breed:breed)
     
            
        end
        dob_ob
    end

    def self.find_by_name(name)
        res = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        dog = Dog.new(id:res[0], name:res[1], breed:res[2])
    end
end
