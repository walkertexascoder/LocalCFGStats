module Leaderboards

  class Standout

    include Enumerable

    def initialize(tags)
      @tags = tags
    end

    attr_reader :tags

    def each
      Result.includes(:competitor, :competition).tagged(tags).finished.order('standout desc').each_with_index do |result, index|
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
            result_id: result.id
        }

        yield attrs
      end
    end

  end

end