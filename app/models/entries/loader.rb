require 'hq/results'
require 'silence'

module Entries

  # load all results obtained from HQ and store locally

  class Loader

    include Silence

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

      def analyze!(peer_group)
        Results::Stats.apply!(peer_group)
      end

      def load_2015_regional!
        HQ::Division.all.each do |division|
          division = division.name

          load_all_super_regions!(year: 2015, stage: 'regional', division: division)

          # fictional ranking across all super regions
          Results::Ranker.rank!(
              {year: 2015, stage: 'regional', division: division},
              {year: 2015, stage: 'regional', division: division, fictional: true}
          )

          # determine standout, etc.
          analyze!(year: 2015, stage: 'regional', division: division, fictional: true)
        end
      end

      def load_all_super_regions!(*args)
        opts = args.first || {}

        HQ::SuperRegion.each do |super_region|
          load!(opts.merge(region: super_region.name))
          analyze!(opts.merge(super_region: super_region.name))
        end
      end

      def load_all_regions(*args)
        opts = args.first || {}

        HQ::Region.each do |region|
          tags = opts.merge(region: region.name)
          load!(tags)
          analyze!(tags)
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
      hq_results = HQ::Results.get(*args)

      # competitions have to be created by hand in order to define the event count,
      # scoring criteria, time caps, etc. see: competition.rb

      competition_tags = build_competition_tags(hq_results)

      competition = Competition.where("tags @> ?", competition_tags.to_json).first
      unless competition
        raise "missing competition for: #{competition_tags}"
      end

      hq_results.each do |name, attrs|
        # create the competitor when seen for the first time. relying upon HQ to use
        # unique ids per competitor across all divisions which seems to hold up so far.

        competitor = Competitor.
            create_with(
                name: name
            ).
            find_or_create_by(hq_id: attrs[:id])

        # jsonb doesn't seem to work with find_or_create_by. we're just going to be
        # creating in a single thread we can do this in multiple statements (and actually
        # AR does anyways).

        # relying upon tags to uniquely identify an entry per competition for a
        # competitor.
        entry_tags = build_entry_tags(hq_results)

        # an entry per (competitor, year, division, stage, region, and super_region)
        entry = Entry.where(competitor_id: competitor.id).where("tags @> ?", entry_tags.to_json).first
        unless entry
          entry = Entry.create(
              competitor_id: competitor.id,
              competition_id: competition.id,
              tags: entry_tags
          )
        end

        attrs[:results].each_with_index do |hq_result, index|
          result = Result.where(entry_id: entry.id, event_num: index + 1).where("tags @> ?", entry_tags.to_json).first
          unless result
            Result.create(
                entry_id: entry.id,
                competitor_id: entry.competitor_id,
                event_num: index + 1,
                tags: entry_tags,
                raw: hq_result[:raw],
                rank: hq_result[:rank],
                competition_id: competition.id,
                entry_id: entry.id
              )
          end

          # must wait to evaluate other result aspects, e.g. mean and std dev, until
          # all results to compare have been created
        end
      end
    end

  end

end