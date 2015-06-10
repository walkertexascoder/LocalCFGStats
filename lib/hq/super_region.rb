require 'simple_enum'

module HQ

  class SuperRegion

    def initialize(name, id)
      @name = name
      @id = id
    end

    attr_reader :name, :id

    @@all = []
    ALL = @@all

    include SimpleEnum

    ATLANTIC = enum('atlantic', 1)
    CALIFORNIA = enum('california', 2)
    CENTRAL = enum('central', 3)
    EAST = enum('east', 4)
    MERIDIAN = enum('meridian', 5)
    PACIFIC = enum('pacific', 6)
    SOUTH = enum('south', 7)
    WEST = enum('west', 8)

  end

end