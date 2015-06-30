class Entry < ActiveRecord::Base

  include CompetitionTags

  validates :competitor_id, presence: true
  validates :tags, presence: true

  belongs_to :competitor
  belongs_to :competition

end