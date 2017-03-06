require 'silence'
require 'hq/division'
require 'hq/super_region'
require 'hq/region'

module Entries::HQ

  class Bootstrapper

    class << self

      # Entries::HQ::Bootstrapper.bootstrap!(year: 2015, stage: 'regional', division: 'men')

      def bootstrap!(*args)
        puts "bootstrapping #{args.inspect}"

        load!(args.first)
        analyze!(*args)
      end

      # Entries::HQ::Bootstrapper.bootstrap_2015_regional_showdown!

      def bootstrap_2015_regional_showdown!
        regional_tags = {
            year: 2015,
            stage: 'regional'
        }

        puts "load actual rankings"
        puts

        load_all_regions!(regional_tags)

        puts
        puts "tag weeks"
        puts

        tag_super_region_2015_weeks!(regional_tags)

        puts
        puts "load fictional rankings by division"
        puts

        rank_fictional_by_division!(regional_tags)

        puts
        puts "load fictional rankings for games qualifiers by division"
        puts

        rank_games_qualifiers_by_division!(regional_tags)
      end

      def bootstrap_2016_regional_showdown!
        regional_tags = {
            year: 2016,
            stage: 'regional'
        }

        puts "load actual rankings"
        puts

        load_all_regions!(regional_tags)

        puts
        puts "tag weeks"
        puts

        tag_super_region_2016_weeks!(regional_tags)

        puts
        puts "load fictional rankings by division"
        puts

        rank_fictional_by_division!(regional_tags)

        puts
        puts "load fictional rankings for games qualifiers by division"
        puts

        rank_games_qualifiers_by_division!(regional_tags)
      end


      private

      include Silence

      def load!(*args)
        Entries::HQ::Loader.load!(*args)
      end

      def analyze!(*args)
        Results::Analyzer.analyze!(*args)
      end

      def rank_fictional!(*args)
        Results::FictionalRanker.rank!(*args)
      end

      def load_all_regions!(tags)
        HQ::Division.each do |division|
          HQ::SuperRegion.each do |super_region|
            bootstrap!(tags.merge(division: division.name, super_region: super_region.name))
          end
        end
      end

      def tag_super_region_2015_weeks!(tags)
        [
            %w[south atlantic],
            %w[california east pacific],
            %w[west central meridian]
        ].each_with_index do |super_regions, index|
          super_regions.each do |super_region|
            silence do
              Result.tagged(tags.merge(super_region: super_region)).each do |result|
                result.tags[:week] = index + 1
                result.save!
              end
            end
          end
        end
      end

      def tag_super_region_2016_weeks!(tags)
        [
            %w[california south pacific],
            %w[west atlantic],
            %w[central meridian east]
        ].each_with_index do |super_regions, index|
          super_regions.each do |super_region|
            silence do
              Result.tagged(tags.merge(super_region: super_region)).each do |result|
                result.tags[:week] = index + 1
                result.save!
              end
            end
          end
        end
      end


      def rank_games_qualifiers_by_division!(tags)
        silence do
          HQ::Division.each do |division|
            puts division.name

            qualifier_ids = []

            HQ::SuperRegion.each do |super_region|
              results = Result.tagged(tags.merge(division: division.name, super_region: super_region.name))
              qualifier_ids += Leaderboards::Overall.new(results, '2015_regional').first(5).map {|r| r[:competitor] }.map(&:id)
            end

            division_tags = tags.merge(division: division.name)

            rank_fictional!(Result.tagged(division_tags).where(competitor_id: qualifier_ids).actual, division_tags.merge(games_qualifier: true))

            analyze!(division_tags.merge(games_qualifier: true, fictional: true))
          end
        end
      end

      def rank_fictional_by_division!(tags)
        HQ::Division.each do |division|
          division_tags = tags.merge(division: division.name)

          # build new results comparing all competitors within each division
          rank_fictional!(Result.tagged(division_tags), division_tags)

          # then analyze them. be sure to only select the fictional results just created.
          analyze!(division_tags.merge(fictional: true))
        end
      end

    end

  end

end