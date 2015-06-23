# not planning to persist this at the moment but we need a place to specify
# events, scoring methods, and timecaps.

class Competition < ActiveRecord::Base

  has_many :entries
  has_many :competitors, through: :entries

  class << self

    def load!
      individuals = %w[men women]

      individuals.each do |division|
        competition year: 2015, stage: 'regional', division: division do
          event 1, :time, time_cap: '6:00'
          event 2, :time, time_cap: '16:00'
          event 3, :time, time_cap: '26:00'
          event 4, :time, time_cap: '3:00'
          event 5, :weight
          event 6, :time, time_cap: '16:00'
          event 7, :time, time_cap: '6:00'
        end
      end

      competition year: 2015, stage: 'regional', division: 'teams' do
        event 1, :time, time_cap: '20:00'
        event 2, :time, time_cap: '25:00'
        event 3, :time, time_cap: '20:00'
        event 4, :weight
        event 5, :time, time_cap: '7:00'
        event 6, :time, time_cap: '25:00'
        event 7, :time, time_cap: '20:00'
      end
    end

    def competition(tags, &block)
      competition = Competition.where("tags @> ?", tags.to_json).first

      unless competition
        competition = Competition.new(tags: tags, events: [])

        if block_given?
          Builder.new(competition).instance_eval(&block)
        end

        competition.save
      end
    end

  end

  private

  class Builder

    def initialize(competition)
      @competition = competition
    end

    def event(num, scoring, opts = {})
      @competition.events << {
          num: num,
          scoring: scoring,
          opts: opts
      }
    end

  end

end