module HQ

  class Stage

    include SimpleEnum

    OPEN = enum('open', 0)
    REGIONAL = enum('regional', 1)
    GAMES = enum('games', 2)

  end

end