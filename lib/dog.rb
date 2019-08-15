require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    @@all = []

    def initialize(name: name, breed: breed, id: id=nil)
        @name = name
        @breed = breed
        @id = id
        @@all << self
    end

    def self.all
        @@all
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(dog)
        self.new(name: dog[1], breed: dog[2], id: dog[0])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql, name).first

        the_dog = self.all.find{|dogs| dogs.id == dog[0]}
    end

    def update
        # sql = <<-SQL
        #     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        # SQL

        DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?', self.name, self.breed, self.id)
    end

    def save
        dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', self.name, self.breed)
        if !dog.empty?
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs(name, breed) VALUES(?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            # binding.pry
        end
        self
    end 

    def self.create(dog)
        new_dog = Dog.new(dog)
        new_dog.save
    end

    def self.find_by_id(id)
        self.all.find{|dog| dog.id == id}
    end

    def self.find_or_create_by(name:, breed:)
        dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dogs.empty?
          dog_data = dogs[0]
          new_dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        else
          new_dog = self.create(name: name, breed: breed)
        end
        new_dog
      end
    
end