module HQ

  class Stage

    include SimpleEnum

    GAMES = enum('games', 2)
    REGIONAL = enum('regional', 1)
    OPEN = enum('open', 0)

  end

end