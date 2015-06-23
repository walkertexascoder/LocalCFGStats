class Competitor < ActiveRecord::Base

  validates :name, presence: true

  validates :hq_id, presence: true,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }

  has_many :entries, dependent: :destroy

end
