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

  def time_capped?(raw)
    timed? && !! (raw =~ /c(\+(\d+))?/i)
  end

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
      time_cap_ms + ((1 + $1.to_i) * 1_000) # remember, ms
    else
      parse_ms(raw_score)
    end
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