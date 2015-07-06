require 'csv'

module Leaderboards

  class Overall

    include Enumerable

    # Leaderboards::Overall.new({year: 2015, division: 'men', games_qualifier: true})

    def initialize(results, scorer = '2015_regional')
      @results = results

      case scorer
        when 'golf'
          scorer = GolfScorer.new
        when '2015_regional'
          scorer = Regional2015Scorer.new
      end

      @scorer = scorer
    end

    attr_reader :results, :scorer

    # each entry consists of [competitor, score]

    def each
      leaderboard.each do |entry|
        yield entry
      end
    end

    def to_csv
      CSV.generate do |csv|
        header = ['Name', 'Score']

        first[:results].count.times do |index|
          event = "Event #{index + 1}"
          header << "#{event} Result"
          header << "#{event} Rank"
          header << "#{event} Score"
          header << "#{event} Std Dev"
          header << "#{event} Mean"
          header << "#{event} Standout"
          header << "#{event} Est Result"
          header << "#{event} Est Std Dev"
          header << "#{event} Est Mean"
          header << "#{event} Est Standout"
        end
        csv << header

        each do |entry|
          csv_row = [ entry[:competitor].name, entry[:score] ]

          entry[:results].each do |result|
            csv_row << result.raw
            csv_row << result.rank
            csv_row << scorer.score(result.rank)
            csv_row << result.raw_std_dev
            csv_row << result.raw_mean
            csv_row << result.standout
            csv_row << result.est_raw
            csv_row << result.est_raw_std_dev
            csv_row << result.est_raw_mean
            csv_row << result.est_standout
          end

          csv << csv_row
        end
      end
    end

    class GolfScorer

      def score(rank)
        rank
      end

      def smaller_score_better?
        true
      end

    end

    class Regional2015Scorer

      LADDER =
          6.times.map {|i| 100 - 5 * i } +
              24.times.map {|i| 73 - 2 * i } +
              27.times.map {|i| 26 - i }

      LADDER_SQL = LADDER.size.times.map {|index| "when #{index + 1} then #{LADDER[index]}" }.join(' ')

      def score(rank)
        if rank > LADDER.size
          raise "score ladder not large enough for rank requested"
        end

        LADDER[rank - 1]
      end

      def smaller_score_better?
        false
      end

    end

    private

    def leaderboard
      @leaderboard ||= build_leaderboard
    end

    def build_leaderboard
      score_by_competitor = Hash.new {|h, k| h[k] = 0 }
      results_by_competitor = Hash.new {|h, k| h[k] = [] }

      find_competition(results).events.each do |event|
        results.includes(:competitor).event(event.num).order(:rank).each do |event_result|
          competitor = event_result.competitor
          score_by_competitor[competitor] += scorer.score(event_result.rank)
          results_by_competitor[competitor] << event_result
        end
      end

      _leaderboard = score_by_competitor.sort_by {|_, score| score }

      if ! scorer.smaller_score_better?
        _leaderboard.reverse!
      end

      _leaderboard.map do |competitor, score|
        {
            competitor: competitor,
            score: score,
            results: results_by_competitor[competitor]
        }
      end
    end

    def find_competition(results)
      competition_ids = results.pluck(:competition_id).uniq

      if competition_ids.size != 1
        raise "expected 1 competition for all provided entries but received #{competition_ids.size}"
      end

      Competition.find(competition_ids.first)
    end


  end

end