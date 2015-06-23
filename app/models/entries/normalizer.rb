module Entries

  class Normalizer

    def normalize!(entries)
      # not terribly efficient but simple and we rarely do this.

      entries.each do |entry|
        entry.competition.events.each do |event|
          add_normalized_result(entry, event)
        end
        entry.save!
      end
    end

    def self.normalize!(entries)
      new.normalize!(entries)
    end

    private

    def add_normalized_result(entry, event)
      result = entry.results.find {|result| result['event_num'] == event['num'] }

      raw_score = result['raw']
      result.merge!(normalized_attrs(raw_score, event))
    end

    NO_SCORE_RECORDED = /^(?:\s*|---|DNF|WD|CUT|MED|--)$/
    MAXIMUM_POSTGRESQL_INTEGER = 2_147_483_647

    # normalized scores should all ensure:
    #   1. the largest values are the best. by sorting desc the best finisher
    #      should be first.
    #   2. unrecorded scores should not conflict with any actually recorded scores.
    #   3. unrecorded scores should be rankable and be considered as the worst result of the field.

    def normalized_attrs(raw_score, event)
      scoring = event['scoring']

      case scoring
        when 'time'
          time_cap = event['opts']['time_cap']

          # remember, largest values should be best.
          {
              normalized: - normalize_time_score(raw_score, time_cap),
              time_capped: time_capped?(raw_score)
          }
        else
          {
              normalized: normalize_weight_or_reps_score(raw_score)
          }
      end
    end

    # miliseconds
    def normalize_time_score(raw_score, time_cap)
      time_cap = parse_ms(time_cap)

      if raw_score.nil? || raw_score =~ NO_SCORE_RECORDED
        MAXIMUM_POSTGRESQL_INTEGER
      elsif time_capped?(raw_score)
        time_cap + ((1 + $1.to_i) * 1_000) # remember, ms
      else
        parse_ms(raw_score)
      end
    end

    def time_capped?(raw_time)
      !! (raw_time =~ /c(\+(\d+))?/i)
    end

    def normalize_weight_or_reps_score(raw_score)
      if raw_score =~ NO_SCORE_RECORDED
        -1
      end
      raw_score =~ /(\d+)/
      $1.to_i
    end

    # the finest granularity that HQ current records are tenths of seconds but that's an awkward unit and it might be
    # a good idea to future proof ourselves against refinements.

    def parse_ms(time)
      (ChronicDuration.parse(time) * 1_000).to_i
    end

  end

end