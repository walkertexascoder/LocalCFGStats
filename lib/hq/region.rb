module HQ

  class Region

    include SimpleEnum
    
    AFRICA = enum('africa', 1)
    ASIA = enum('asia', 2)
    AUSTRALIA = enum('australia', 3)
    CANADA_EAST = enum('canada_east', 4)
    CANADA_WEST = enum('canada_west', 5)
    CENTRAL_EAST = enum('central_east', 6)
    EUROPE = enum('europe', 7)
    LATIN_AMERICA = enum('latin_america', 8)
    MID_ATLANTIC = enum('mid_atlantic', 9)
    NORTH_CENTRAL = enum('north_central', 10)
    NORTH_EAST = enum('north_east', 11)
    NORTHERN_CALIFORNIA = enum('northern_california', 12)
    NORTH_WEST = enum('north_west', 13)
    SOUTH_CENTRAL = enum('south_central', 14)
    SOUTH_EAST = enum('south_east', 15)
    SOUTHERN_CALIFORNIA = enum('southern_california', 16)
    SOUTH_WEST = enum('south_west', 17)

  end

end