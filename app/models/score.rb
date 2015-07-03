class Score # because Results::Score conflicts with a testing class... :/

  def initialize(event)
    @event = event
  end

  attr_reader :event

  # normalized scores should all ensure:
  #   1. the largest values are the best. by sorting desc the best finisher
  #      should be first.
  #   2. unrecorded scores should not conflict with any actually recorded scores.
  #   3. unrecorded scores should be rankable and be considered as the worst result of the field.

  def to_raw(normalized)
    if timed?
      raw_timed_score(normalized)
    else
      raw_weight_or_reps_score(normalized)
    end
  end

  def to_normalized(raw)
    if timed?
      - normalize_time_score_ms(raw)
    else
      normalize_weight_or_reps_score(raw)
    end
  end

  def to_est_normalized(raw)
    if time_capped?(raw)
      - est_normalized_time_score_ms(raw)
    else
      to_normalized(raw)
    end
  end

  def time_capped?(raw)
    timed? && !! (raw =~ /c(\+(\d+))?/i)
  end

  delegate :reps, to: :event

  private

  delegate :timed?, :time_cap_ms, to: :event

  NO_SCORE_RECORDED = /^(?:\s*|---|DNF|WD|CUT|MED|--)$/
  MAXIMUM_POSTGRESQL_INTEGER = 2_147_483_647

  def normalized_time_capped?(normalized)
    time_cap_ms && (- normalized) > time_cap_ms
  end

  def raw_timed_score(normalized)
    if normalized_time_capped?(normalized)
      difference = - (normalized + time_cap_ms)
      "C+#{difference / 1_000}"
    else
      ChronicDuration.output(- (normalized / 1_000.0), format: :chrono)
    end
  end

  def raw_weight_or_reps_score(normalized)
    normalized.to_s
  end

  def normalize_time_score_ms(raw_score)
    if raw_score.nil? || raw_score =~ NO_SCORE_RECORDED
      MAXIMUM_POSTGRESQL_INTEGER
    elsif time_capped?(raw_score)
      # unless estimating, always assume 1_000 ms per penalty unit
      time_cap_ms + (penalty_units(raw_score) * 1_000)
    else
      parse_ms(raw_score)
    end
  end

  def est_normalized_time_score_ms(raw_score)
    time_cap_ms + penalty_ms(raw_score)
  end

  def penalty_units(raw)
    raw =~ /c(\+(\d+))?/i
    $1.to_i
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

  def penalty_ms(raw)
    remaining_units = penalty_units(raw)

    if reps
      if reps.is_a?(Hash)
        result = 0
        reps.to_a.reverse.each do |raw_s_per_rep, _reps|
          ms_per_rep = parse_ms(raw_s_per_rep)

          if _reps > remaining_units
            return result + remaining_units * ms_per_rep
          else
            remaining_units -= _reps
            result += _reps * ms_per_rep
          end
        end
      else
        ms_per_rep = time_cap_ms / reps.to_f
        remaining_units * ms_per_rep
      end
    else
      remaining_units * 1_000 # assume one second / rep
    end
  end

end