require 'simple_enum'

module HQ

  class Division

    def initialize(name, id)
      @name = name
      @id = id
    end

    attr_reader :name, :id

    include SimpleEnum

    MEN = enum('men', 101)
    WOMEN = enum('women', 201)
    TEAMS = enum('teams', 301)

  end

end