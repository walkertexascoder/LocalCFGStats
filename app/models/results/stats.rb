require 'sql_executor'
require 'silence'

module Results

  class Stats

    include Silence

    # add to each score:
    #
    #   1. std_dev - standard dev of scores of all event finishers
    #   2. mean - mean of scores of all event finishers
    #   3. est_std_dev - standard dev of scores of *all* competitors, with non-finishers estimated by avg rep / s
    #   4. est_mean - mean of scores of *all* competitors, with non-finishers estimated as for est_std_dev
    #
    # all entries should belong to the same competition

    # Entries::Scout.apply!(Competition.first.entries)

    include SqlExecutor

    def apply!(tags)
      apply_loudly!(tags)
    end

    def self.apply!(tags)
      new.apply!(tags)
    end

    private

    def apply_loudly!(tags)
      silence do
        results = Result.tagged(tags)

        find_competition(results).events.each do |event|
          add_for_finishers(results, event)
          # add_estimated_for_all(entry_ids, index)
        end
      end
    end

    def find_competition(results)
      competition_ids = results.map(&:competition_id).uniq
      if competition_ids.size != 1
        raise "expected 1 competition for all provided entries but received #{competition_ids.size}"
      end

      Competition.find(competition_ids.first)
    end

    def add_for_finishers(results, event)
      result_ids, normalized = results.event_num(event.num).finished.pluck(:id, :normalized).transpose

      if normalized.blank?
        puts "no finishers for event #{event.num}"
        return
      end

      stats = DescriptiveStatistics::Stats.new(normalized)
      std_dev = stats.standard_deviation || 0
      mean = stats.mean

      result_ids.each do |id|
        # one by one since we want to do some more advanced converstion of normalized
        # to raw. not to mention we're likely going to serialize these into a more
        # succinct form so as to serve them up
        result = Result.find(id)

        result.update!(
          std_dev: std_dev,
          raw_std_dev: format_normalized_stat(std_dev, result.event),
          mean: mean,
          raw_mean: format_normalized_stat(mean, result.event),
          standout: (result.normalized - mean) / (std_dev.zero? ? 1 : std_dev)
        )
      end
    end

    def format_normalized_stat(normalized, event)
      if event.timed?
        if normalized < 0
          normalized = - normalized
        end

        normalized = (normalized / 1_000).round(2)

        raw = ChronicDuration.output(normalized, format: :chrono)

        raw.gsub(/:(\d)\./, ':0\1.')
      else
        normalized.round(2).to_s
      end
    end

  end

end