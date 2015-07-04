class Result < ActiveRecord::Base

  include CompetitionTags

  belongs_to :competition
  belongs_to :entry
  has_one :competitor, through: :entry
  has_many :scores

  scope :attempted, -> { where("raw is not null") }
  scope :not_attempted, -> { where("raw is null") }
  scope :not_time_capped, -> { where("time_capped = false") }
  scope :time_capped, -> { where("time_capped = true") }
  scope :finished, -> { attempted.not_time_capped }
  scope :event, -> (num) { where(event_num: num) }

  scope :fictional, -> { tagged(fictional: true) }

  before_save :normalize, if: -> { normalized.blank? }

  def event
    competition.events[event_num - 1] # 0 based
  end

  def finished?
    raw.present? && ! time_capped?
  end

  private

  def normalize
    if raw.present?
      score = Score.new(event)

      self.normalized = score.to_normalized(raw)
      self.time_capped = score.time_capped?(raw)
      self.est_normalized = score.to_est_normalized(raw)
      self.est_raw = score.to_est_raw(est_normalized)
      # helpful to understand how estimates were generated.
      self.est_reps = score.reps
    end

    true
  end

end
