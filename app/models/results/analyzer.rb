require 'sql_executor'
require 'silence'

module Results

  class Analyzer

    include Silence
    include SqlExecutor

    def analyze!(*args)
      apply_loudly!(*args)
    end

    def self.analyze!(*args)
      new.analyze!(*args)
    end

    private

    def apply_loudly!(tags, opts = {})
      silence do
        results = Result.tagged(tags)

        # we should only be analyzing results within a distinct tag set. we could possible
        # go too broadly, e.g. "divison: men" and we would compare across fictional and
        # actual resutls which we would never want.

        if results.select('distinct(tags)').count != 1
          raise "expected tags to select a unique tag set: #{tags}"
        end

        find_competition(results).events.each do |event|
          add_analysis!(results, event)
        end
      end
    end

    def find_competition(results)
      competition_ids = results.pluck(:competition_id).uniq

      if competition_ids.size != 1
        raise "expected 1 competition for all provided entries but received #{competition_ids.size}"
      end

      Competition.find(competition_ids.first)
    end

    def add_analysis!(results, event)
      attempted = results.event(event.num).attempted

      finished_ids, finished_normalized = attempted.not_time_capped.pluck(:id, :normalized).transpose
      std_dev, mean = stats(finsihed_normalized)

      time_capped = attempted.time_capped

      time_capped_ids, time_capped_est_normalized = time_capped.pluck(:id, :est_normalized)
      est_std_dev, est_mean = stats(finished_normalized + time_capped_est_normalized)

      # if we want to make this faster (e.g. batch SQL update) then we'll need to do some things like learn how
      # to convert from normalized to raw based on event types within SQL.

      (finished_ids + time_capped_ids).each do |id|
        add_result_analysis!(id, std_dev, mean, est_std_dev, est_mean)
      end
    end

    def stats(normalized)
      stats = DescriptiveStatistics::Stats.new(normalized)

      std_dev = stats.standard_deviation || 0
      mean = stats.mean

      [std_dev, mean]
    end

    def stat_attrs(result, std_dev, mean, prefix = '')
      {
          "#{prefix}std_dev" => std_dev,
          "#{prefix}raw_std_dev" => format_normalized(std_dev, result.event),
          "#{prefix}mean" => mean,
          "#{prefix}raw_mean" => format_normalized(mean, result.event)
      }
    end

    def add_result_analysis!(id, std_dev, mean, est_std_dev, est_mean)
      # one by one since we want to do some more advanced converstion of normalized
      # to raw. not to mention we're likely going to serialize these into a more
      # succinct form so as to serve them up
      result = Result.find(id)

      # event if this result has no normalized value (not completed) we can still populate the
      # statistics for those who did complete.
      attrs = stat_attrs(result, std_dev, mean)

      attrs.merge!(stat_attrs(result, est_std_dev, est_mean, :est_))

      if result.finished?
        # we only know their actual standout is if no estimation is involved.
        attrs.merge!(standout: standout(result.normalized, mean, std_dev))
      end

      result.update!(attrs)
    end

    def standout(normalized, mean, std_dev)
      (normalized - mean) / (std_dev.zero? ? 1 : std_dev)
    end

    def format_normalized(normalized, event)
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