require 'hq/results'

module Entries

  # load all results obtained from HQ and store locally

  class Loader

    # region and super region will both be passed in the "region" parameter
    def initialize(*args)
      @args = args
    end

    def load!
      silence do
        load_loudly!
      end
    end

    class << self

      def load!(*args)
        new(*args).load!
      end

      def load_all_super_regions!(*args)
        opts = args.first || {}

        HQ::SuperRegion.each do |super_region|
          load!(opts.merge(region: super_region.name))
        end
      end

      def load_all_regions(*args)
        opts = args.first || {}

        HQ::Region.each do |region|
          load!(opts.merge(region: region.name))
        end
      end

    end

    private

    attr_reader :args

    def build_entry_tags(results)
      {
          year: results.year,
          division: results.division,
          stage: results.stage,
          region: results.region,
          super_region: results.super_region
      }
    end

    def build_competition_tags(results)
      {
          year: results.year,
          division: results.division,
          stage: results.stage
      }
    end

    def load_loudly!
      results = HQ::Results.get(*args)

      results.each do |name, attrs|
        # create the competitor when seen for the first time. relying upon HQ to use
        # unique ids per competitor across all divisions which seems to hold up so far.

        competitor = Competitor.
            create_with(
                name: name
            ).
            find_or_create_by(hq_id: attrs[:id])

        # competitions have to be created by hand in order to define the event count,
        # scoring criteria, time caps, etc. see: competition.rb

        competition_tags = build_competition_tags(results)

        competition = Competition.where("tags @> ?", competition_tags.to_json).first
        unless competition
          raise "missing competition for: #{competition_tags}"
        end

        # jsonb doesn't seem to work with find_or_create_by. we're just going to be
        # creating in a single thread we can do this in multiple statements (and actually
        # AR does anyways).

        # relying upon tags to uniquely identify an entry per competition for a
        # competitor.
        entry_tags = build_entry_tags(results)

        # an entry per (competitor, year, division, stage, region, and super_region)
        entry = Entry.where(competitor_id: competitor.id).where("tags @> ?", entry_tags.to_json).first
        unless entry
          entry = Entry.new(
              competitor_id: competitor.id,
              competition_id: competition.id,
              tags: entry_tags,
              results: attrs[:results]
          )
          entry.normalize!
        end
      end
    end

    def silence
      # what happened to ActiveRecord::Base.silence?
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil

      begin
        yield
      ensure
        ActiveRecord::Base.logger = old_logger
      end
    end

  end

end