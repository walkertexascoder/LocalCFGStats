require 'sql_executor'
require 'silence'

module Results

  class Ranker

    include Silence
    include SqlExecutor

    # Results::Ranker.rank!({division: 'teams'}, {year: 2015, stage: 'regional', division: 'teams', region: nil, super_region: nil, fictional: true})

    def rank!(*args)
      silence do
        rank_loudly!(*args)
      end
    end

    def self.rank!(*args)
      new.rank!(*args)
    end

    private

    def rank_loudly!(from_tags, to_tags)
      results = Result.tagged(from_tags)

      find_competition(results).events.each do |event|
        _score!(results, to_tags, event)
      end
    end

    def find_competition(results)
      competition_ids = results.map(&:competition_id).uniq
      if competition_ids.size != 1
        raise "expected 1 competition for all provided entries but received #{competition_ids.size}"
      end

      Competition.find(competition_ids.first)
    end

    def _score!(results, to_tags, event)
      results = results.event_num(event.num)

      # bigger is always better for all normalized values
      ordered = results.sort_by {|result| - result.normalized }

      ordered.each_with_index do |result, index|
        rank = index + 1

        to_result = Result.where(entry_id: result.entry_id, event_num: result.event_num).where("tags @> ?", to_tags.to_json).first
        unless to_result
          Result.create(
            tags: to_tags,
            competition_id: result.competition_id,
            entry_id: result.entry_id,
            event_num: result.event_num,
            raw: result.raw,
            normalized: result.normalized,
            time_capped: result.time_capped,
            rank: rank
          )
        end
      end
    end

  end

end