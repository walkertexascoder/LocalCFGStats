module CompetitionTags

  extend ActiveSupport::Concern

  included do

    scope :tagged, -> (tags) { where("tags @> ?", tags.to_json) }

    scope :division, -> (division) { tagged(division: division) }
    scope :men, -> { division(:men) }
    scope :women, -> { division(:women) }
    scope :teams, -> { division(:teams) }

    scope :stage, -> (stage) { tagged(stage: stage ) }
    scope :games, -> { stage(:games) }
    scope :regional, -> { stage(:regional) }
    scope :open, -> { stage(:open) }

    scope :year, -> (year) { tagged(year: year) }

    scope :region, -> (region) { tagged(region: region) }
    scope :across_regions, -> { tagged(region: nil) }

    scope :super_region, -> (super_region) { tagged(super_region: super_region) }
    scope :across_super_regions, -> { tagged(super_region: nil) }

  end

end