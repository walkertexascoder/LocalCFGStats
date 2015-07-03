module Entries::HQ

  class Bootstrapper

    class << self

      def bootstrap!(*args)
        load!(args.first)
        analyze!(*args)
      end

      def bootstrap_2015_regional_showdown!
        regional_tags = {
            year: 2015,
            stage: 'regional'
        }

        # load all actual results
        HQ::Division.each do |division|
          HQ::SuperRegion.each do |super_region|
            bootstrap!(regional_tags.merge(division: division, super_region: super_region))
          end
        end

        # build fictional showdown results
        HQ::Division.each do |division|
          tags = regional_tags.merge(division: division)

          # build new results comparing all competitors within each division
          rank_fictional!(tags)

          # then analyze them. be sure to only select
          analyze!(tags.merge(fictional: true))
        end
      end

      private

      def load!(*args)
        Entries::HQ::Loader.load!(*args)
      end

      def analyze!(*args)
        Results::Analyzer.analyze!(*args)
      end

      def rank_fictional!(*args)
        Results::FictionalRanker.rank!(*args)
      end

    end

  end

end