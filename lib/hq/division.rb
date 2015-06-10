require 'simple_enum'

module HQ

  class Division

    include SimpleEnum

    MEN = enum('men', 101)
    WOMEN = enum('women', 201)
    TEAMS = enum('teams', 301)

  end

end