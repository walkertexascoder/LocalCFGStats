class Result < ActiveRecord::Base

  include CompetitionTags

  belongs_to :competition
  belongs_to :entry
  has_one :competitor, through: :entry
  has_many :scores

  scope :attempted, -> { where("raw is not null") }
  scope :not_time_capped, -> { where("time_capped = false") }
  scope :finished, -> { attempted.not_time_capped }
  scope :event_num, -> (num) { where(event_num: num) }

  scope :fictional, -> { tagged(fictional: true) }

  before_save :normalize, if: -> { normalized.blank? }

  def event
    competition.events[event_num - 1] # 0 based
  end

  private

  def normalize
    self.normalized = normalize_raw
    self.time_capped = time_capped?(raw)
    true
  end

end
