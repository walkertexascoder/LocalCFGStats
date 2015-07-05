require 'sql_executor'
require 'silence'

module Results

  class FictionalRanker

    include Silence
    include SqlExecutor

    # Results::Ranker.rank!(results, {year: 2015, stage: 'regional', division: 'men'})

    def rank!(*args)
      silence do
        rank_loudly!(*args)
      end
    end

    def self.rank!(*args)
      new.rank!(*args)
    end

    private

    def rank_loudly!(results, new_tags)
      # safeguard...
      new_tags[:fictional] = true

      if Result.tagged(new_tags).exists?
        raise "results already exist for #{new_tags}"
      end

      find_competition(results).events.each do |event|
        rank_for_event!(results, new_tags, event)
      end
    end

    def find_competition(results)
      competition_ids = results.pluck(:competition_id).uniq

      # it is essential that we only rank using a single set of events, which includes
      # momvents, weights, and scaling. this is the definition of a "competition".
      if competition_ids.size != 1
        raise "expected 1 competition for all provided entries but received #{competition_ids.size}"
      end

      Competition.find(competition_ids.first)
    end

    def rank_for_event!(results, new_tags, event)
      last_normalized = nil
      rank_for_normalized = nil

      results.event(event.num).joins(:competitor).order('normalized desc nulls last, name desc').each_with_index do |result, index|
        if index > 0 && last_normalized == result.normalized
          # scores are the same. we should leave the rank the same.
        elsif
          rank_for_normalized = index + 1
        end

        attrs = result.attributes
        attrs.delete('id')

        Result.create(attrs.merge(rank: rank_for_normalized, tags: new_tags))

        last_normalized = result.normalized
      end
    end

  end

end