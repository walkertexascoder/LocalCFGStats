module Leaderboards

  class Standout

    include Enumerable

    # l = Leaderboards::Standout.new(year: 2015, stage: 'regional', fictional: true)
    # l.reject {|r| r[:event_num] == 3 && r[:division].in?(%w[men women]) }.first(10)

    def initialize(tags)
      @tags = tags
    end

    attr_reader :tags

    def each
      Result.includes(:competitor, :competition).tagged(tags).finished.order('est_standout desc').each_with_index do |result, index|
        attrs = {
            rank: index + 1,
            competitor: result.competitor.name,
            division: result.tags['division'],

            event: result.event.name,
            event_num: result.event_num,

            raw: result.raw,
            normalized: result.normalized,
            mean: result.mean,
            std_dev: result.std_dev,
            standout: result.standout,
            result_id: result.id,

            est_raw: result.est_raw,
            est_normalized: result.est_normalized,
            est_mean: result.est_mean,
            est_std_dev: result.est_std_dev,
            est_standout: result.est_standout
        }

        yield attrs
      end
    end

  end

end