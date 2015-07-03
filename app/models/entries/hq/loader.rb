require 'hq/results'
require 'silence'

module Entries::HQ

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

    def self.load!(*args)
      new(*args).load!
    end

    private

    attr_reader :args

    def load_loudly!
      hq_results = HQ::Results.get(*args)

      # HQ returns a single leaderboard which belongs to exactly one Competition
      competition = find_competiton!(hq_results)

      hq_results.each do |competitor_name, hq_results_attrs|
        # each result corresponds to an entry in the leaderboard, i.e. competitor and their event results
        load_results!(competitor_name, hq_results_attrs, competition)
      end
    end

    def find_competiton!(hq_results)
      tags = {
          year: hq_results.year,
          division: hq_results.division,
          stage: hq_results.stage
      }

      competition = Competition.tagged(tags).first

      unless competition
        raise "missing competition for: #{tags}"
      end

      competition
    end

    def load_results!(competitor_name, hq_results_attrs, competition)
      competitor = load_competitor!(competitor_name, hq_results_attrs)

      entry = load_entry!(competitor, competition, hq_results_attrs)

      hq_results_attrs[:results].each_with_index do |hq_result_attrs, index|
        load_result!(entry, hq_result_attrs, index)
      end
    end

    # create the competitor when seen for the first time. relying upon HQ to use
    # unique ids per competitor across all divisions which seems to hold up so far.

    def load_competitor!(competitor_name, hq_entry_attrs)
      Competitor.
          create_with(
              # if the games site changes the capitalization between years, or over time, we don't want to load
              # the same competitor multiple times.
              name: competitor_name
          ).
          find_or_create_by(hq_id: hq_entry_attrs[:id])
    end

    def load_entry!(competitor, competition, hq_results_attrs)
      entry_tags = {
          year: hq_results_attrs.year,
          division: hq_results_attrs.division,
          stage: hq_results_attrs.stage,
          region: hq_results_attrs.region,
          super_region: hq_results_attrs.super_region
      }

      entry = Entry.where(
          competitor_id: competitor.id
      ).tagged(entry_tags).first

      unless entry
        entry = Entry.create(
            competitor_id: competitor.id,
            competition_id: competition.id,
            tags: entry_tags
        )
      end

      entry
    end

    def load_result!(entry, hq_result_attrs, index)
      result = Result.where(
          entry_id: entry.id,
          event_num: index + 1
      ).tagged(result_tags).first

      unless result
        result = Result.create(
            entry_id: entry.id,
            competitor_id: entry.competitor_id,
            event_num: index + 1,
            tags: entry.tags,
            raw: hq_result[:raw],
            rank: hq_result[:rank],
            competition_id: competition.id,
            entry_id: entry.id
        )
      end

      # must wait to evaluate other result aspects, e.g. mean and std dev, until
      # all results to compare have been created
      result
    end

  end

end