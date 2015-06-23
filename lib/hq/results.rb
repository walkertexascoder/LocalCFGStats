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
      @year = year.to_i
      @division = division
      @stage = stage

      # regions < 2015, super regions >= 2015 for regionals
      # always for opens
      if (@year < 2015 && stage == 'regional') || stage == 'open'
        @region = region
      else
        @super_region = region
      end
    end

    def get
      self
    end

    attr_reader :year, :division, :stage, :region, :super_region

    include Enumerable

    def each
      parsed_results.each do |*result|
        yield *result
      end
    end

    def to_csv
      event_count = parsed_results.first.second[:results].size

      CSV.generate do |csv|
        header = ['Name']
        event_count.times do |index|
          event = "Event #{index + 1}"
          header << "#{event} Result"
          header << "#{event} Rank"
          header << "#{event} Score"
        end
        csv << header

        each do |name, attrs|
          result_attrs = attrs[:results]

          csv_row = [name]
          result_attrs.each do |result|
            csv_row << result[:raw]
            csv_row << result[:rank]
            csv_row << result[:score]
          end
          csv << csv_row
        end
      end
    end

    private

    URL = "http://games.crossfit.com/scores/leaderboard.php"
    URL_PARAMS = {
        # these must be populated.
        division_id: nil,
        region: nil,
        year: nil,
        regional: nil, # if not defaulted we get different regions :/
        competition: nil,

        # not sure about the rest of these. will leave them as is.
        stage_id: 0,
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

    def parsed_results
      @parsed_results ||= parse_results
    end

    def parse_results
      all = {} # hashes are ordered as of 1.9. :yey:!

      page.all('tr').each do |row|
        next if row.all('td').empty?

        name, id, results = parse_results_row(row)

        all[name] = {
            id: id,
            results: results
        }
      end

      all
    end

    def parse_results_row(row)
      name = nil
      id = nil
      results = []

      row.all('td').each do |cell|
        if /number/ =~ cell['class']
          next
        elsif /name/ =~ cell['class']
          begin
            cell.find('a')['href'] =~ /(\d+)$/
            id = $1.to_i
          rescue
            puts "unable to parse competitor id" unless year == 2011
          end

          name = cell.text.strip
        else
          results << parse_result(cell.text.strip)
        end
      end

      results.each_with_index do |result, index|
        result[:event_num] = index + 1
      end

      [name, id, results]
    end

    def parse_result(result)
      if stage != 'games' && (year < 2015 || stage == 'open')
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
          raw: $2
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
          raw: result
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
        division_id: parse_division,
        region: parse_region,
        regional: parse_super_region || 1,
        competition: parse_stage
      )

      "#{URL}?#{params.to_param}"
    end

  end

end