require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL
    cols.map!(&:to_sym)
    @columns = cols

  end

  def self.finalize!

    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    "#{self}s".downcase
  end

  def self.all
    arr = DBConnection.execute(<<-SQL)
    SELECT
      "#{table_name}".*
    FROM
      "#{table_name}"
      SQL
      parse_all(arr)
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    # ...
    arr = DBConnection.execute(<<-SQL, id)
      SELECT
        "#{table_name}".*
      FROM
        "#{table_name}"
      WHERE
        "#{table_name}".id = ?
    SQL
    parse_all(arr).first
  end


  def initialize(params = {})
    params.each do |key, value|
      name = key.to_sym
      if self.class.columns.include?(name)
        self.send("#{name}=", value)
      else
        raise "unknown attribute 'favorite_band'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values

  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
