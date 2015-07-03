require 'sql_executor'
require 'silence'

module Results

  class FictionalRanker

    include Silence
    include SqlExecutor

    # Results::Ranker.rank!(year: 2015, stage: 'regional', division: 'men')

    def rank!(*args)
      silence do
        rank_loudly!(*args)
      end
    end

    def self.rank!(*args)
      new.rank!(*args)
    end

    private

    def rank_loudly!(tags)
      results = Result.tagged(tags)

      new_tags = tags.merge(fictional: true)

      if Result.tagged(new_tags).exist?
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
      results.event(event.num).order('normalized desc').each_with_index do |result, index|
        Result.create(result.attrs.merge(rank: index + 1, tags: new_tags))
      end
    end

  end

end