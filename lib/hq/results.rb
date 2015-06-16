require 'open-uri'
require 'capybara'

require 'hq/division'
require 'hq/region'
require 'hq/super_region'
require 'hq/stage'

module HQ

  class Results

    def self.get(*args)
      new(*args).get
    end

    # region and super region will both be passed in the "region" parameter
    def initialize(year: 2015, division: 'men', stage: 'regional', region: 'south')
      @year = year
      @division = division
      @stage = stage

      # regions < 2015, super regions >= 2015
      if year < 2015
        @region = region
      else
        @super_region = region
      end
    end

    def get
      parse_results(page)
    end

    attr_reader :year, :division, :region, :super_region, :stage

    private

    URL = "http://games.crossfit.com/scores/leaderboard.php"
    URL_PARAMS = {
        # these must be populated.
        division: nil,
        region: nil,
        year: nil,
        regional: nil,
        competition: nil,

        # not sure about the rest of these. will leave them as is.
        stage: 0,
        sort: 0,
        page: 0,
        numberperpage: 60,
        frontpage: 0,
        expanded: 1,
        full: 1,
        showtoggles: 0,
        hidedropdowns: 0,
        showathleteac: 1,
        athletename: '',
        fittest: 1,
        fitSelect: 14,
        scaled: 0
    }

    def parse_year
      year.to_s =~ /(\d\d)$/
      $1
    end

    def parse_division
      find_id(HQ::Division, division)
    end

    def parse_region
      find_id(HQ::Region, region)
    end

    def parse_super_region
      find_id(HQ::SuperRegion, super_region)
    end

    def parse_stage
      find_id(HQ::Stage, stage)
    end

    def find_id(enum, name)
      enum.find do |e|
        e.name == name
      end.try(:id)
    end

    def parse_results(page)
      all = {} # hashes are ordered as of 1.9. :yey:!

      page.all('tr').each do |row|
        next if row.all('td').empty?

        name, results = parse_results_row(row)

        all[name] = {
            id: ,
            results: results
        }
      end

      all
    end

    def parse_results_row(row)
      name = nil
      results = []

      row.all('td').each do |cell|
        if /number/ =~ cell['class']
          next
        elsif /name/ =~ cell['class']
          name = cell.text.strip
        else
          results << parse_result(cell.text.strip)
        end
      end

      [name, results]
    end

    def parse_result(result)
      if year < 2015
        parse_2011_result(result)
      else
        parse_2015_result(result)
      end
    end

    def parse_2011_result(result)
      result =~ /(\d+)T?\s*\((.+)\)$/
      {
          rank: $1.to_i,
          score: $1.to_i,
          result: $2
      }
    end

    def parse_2015_result(result)
      result.gsub!(/\s*lb\s*/, '')
      result =~ /^(\d+)[a-zA-Z]+\s*(\d+)\s*pts(.+)$/
      rank, score, result = $1, $2, $3

      if result
        result.gsub!(/^\s*0+/, '')
        result.gsub!(/cap/i, 'C')
        # seeing "C" alone makes one think something is missing
        result.gsub!(/^C$/, 'C+0')
      end

      {
          rank: rank.to_i,
          score: score.to_i,
          result: result
      }
    end

    def page
      puts "URL: #{url}"
      html = open(url).read
      Capybara.string(html)
    end

    def url
      params = URL_PARAMS.merge(
        year: parse_year,
        division: parse_division,
        region: parse_region,
        regional: parse_super_region,
        competition: parse_stage
      )

      "#{URL}?#{params.to_param}"
    end

  end

end