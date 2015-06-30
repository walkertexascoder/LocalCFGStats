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
          add_estimated_for_all(entry_ids, index)
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

      execute_sql <<-SQL
        update results
           set std_dev = #{std_dev},
               mean = #{mean},
               standout = (normalized - #{mean}) / #{std_dev.zero? ? 1 : std_dev}
         where id in (#{result_ids.join(',')})
      SQL
    end

  end

end