class Dog
    def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  #creating a table
  def self.create_table
      DB[:conn].execute(<<-SQL)
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
    end
    def self.drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end
    def save
      if self.id
        update
      else
        DB[:conn].execute(<<-SQL, name, breed)
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end

    def self.new_from_db(row)
      id, name, breed = row
      Dog.new(id: id, name: name, breed: breed)
    end

    def self.all
      rows = DB[:conn].execute("SELECT * FROM dogs")
      rows.map { |row| new_from_db(row) }
    end

    def self.find_by_name(name)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
      new_from_db(row) if row
    end

    def self.find(id)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
      new_from_db(row) if row
    end


end