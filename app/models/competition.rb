# not planning to persist this at the moment but we need a place to specify
# events, scoring methods, and timecaps.

class Competition < ActiveRecord::Base

  include CompetitionTags

  has_many :entries
  has_many :competitors, through: :entries
  has_many :results
  has_many :scores, through: :results

  def events
    @events ||= build_events
  end

  # we're trying to keep rows slim since we're on a free heroku instance. i don't think
  # we'll need to be querying based on event characteristics (yet).

  class Event

    def initialize(attrs)
      @num = attrs['num']
      @name = attrs['name']
      @scoring = attrs['scoring']

      @opts = attrs['opts'] || {}
      @opts = @opts.with_indifferent_access
    end

    attr_reader :num, :name, :scoring, :opts

    def timed?
      scoring == 'time'
    end

    def time_cap
      opts[:time_cap]
    end

    def time_cap_ms
      time_cap && (ChronicDuration.parse(time_cap) * 1_000).to_i
    end

  end

  private

  def build_events
    event_attrs.map do |event_attrs|
      Event.new(event_attrs)
    end
  end

  class << self

    def load!
      individuals = %w[men women]

      individuals.each do |division|
        competition year: 2015, stage: 'regional', division: division do
          event 1, 'Randy', :time, time_cap: '6:00'
          event 2, 'Tommy V', :time, time_cap: '16:00'
          event 3, 'Chipper', :time, time_cap: '26:00'
          event 4, '250\' HS Walk', :time, time_cap: '3:00'
          event 5, '1RM Snatch', :weight
          event 6, 'Row, C2B, HSPU', :time, time_cap: '16:00'
          event 7, 'MU, Clean Ladder', :time, time_cap: '6:00'
        end
      end

      competition year: 2015, stage: 'regional', division: 'teams' do
        event 1, 'Partner DL, C2B', :time, time_cap: '20:00'
        event 2, 'Snatches, Rope Climbs, Thrusters', :time, time_cap: '25:00'
        event 3, 'Run, Wall Balls', :time, time_cap: '20:00'
        event 4, '1RM Snatch', :weight
        event 5, '6x100\' HS Walk', :time, time_cap: '7:00'
        event 6, 'GHD, MU, HPC', :time, time_cap: '25:00'
        event 7, 'Row, HSPU, T2B, OH Lunge', :time, time_cap: '20:00'
      end
    end

    def competition(tags, &block)
      competition = Competition.where("tags @> ?", tags.to_json).first

      unless competition
        competition = Competition.new(tags: tags, event_attrs: [])

        if block_given?
          Builder.new(competition).instance_eval(&block)
        end

        competition.save
      end
    end

  end

  class Builder

    def initialize(competition)
      @competition = competition
    end

    def event(num, name, scoring, opts = {})
      @competition.event_attrs << {
          num: num,
          name: name,
          scoring: scoring,
          opts: opts
      }
    end

  end

end