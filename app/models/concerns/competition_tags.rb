module CompetitionTags

  extend ActiveSupport::Concern

  included do

    scope :tagged, -> (tags) { where("#{self.table_name}.tags @> ?", tags.to_json) }
    scope :with_tag, -> (tag) { where("#{self.table_name}.tags ? '#{tag}'") }
    scope :without_tag, -> (tag) { where("not (#{self.table_name}.tags ? '#{tag}')") }

    scope :not_for_optional_tag, -> (tag) { where("(not (#{self.table_name}.tags ? '#{tag}')) or (#{self.table_name}.tags @> '#{ { tag => false }.to_json }')") }

    scope :division, -> (division) { tagged(division: division) }
    scope :men, -> { division(:men) }
    scope :women, -> { division(:women) }
    scope :women, -> { division(:women) }
    scope :teams, -> { division(:teams) }

    scope :stage, -> (stage) { tagged(stage: stage ) }
    scope :games, -> { stage(:games) }
    scope :regional, -> { stage(:regional) }
    scope :open, -> { stage(:open) }

    scope :year, -> (year) { tagged(year: year) }

    scope :region, -> (region) { tagged(region: region) }
    scope :super_region, -> (super_region) { tagged(super_region: super_region) }

    # definiing this as without region *and* without super region. this will most likely be the only
    # necessary use and it will save some typing :)
    scope :without_region, -> { without_tag(:region).without_tag(:super_region) }

    scope :fictional, -> { tagged(fictional: true) }
    scope :actual, -> { not_for_optional_tag(:fictional) }

    scope :games_qualifier, -> { tagged(games_qualifier: true) }
    scope :not_games_qualifier, -> { not_for_optional_tag(:games_qualifier ) }

  end

end