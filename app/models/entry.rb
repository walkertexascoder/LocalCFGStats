class Entry < ActiveRecord::Base

  validates :competitor_id, presence: true
  validates :tags, presence: true

  belongs_to :competitor
  belongs_to :competition

  def normalize!
    Entries::Normalizer.normalize!([self])
  end

end