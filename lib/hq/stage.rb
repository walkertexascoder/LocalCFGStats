module HQ

  class Stage

    def initialize(name, id)
      @name = name
      @id = id
    end

    attr_reader :name, :id

    include SimpleEnum

    OPEN = enum('open', 0)
    REGIONAL = enum('regional', 1)
    GAMES = enum('games', 2)

  end

end