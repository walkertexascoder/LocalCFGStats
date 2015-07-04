require 'test_helper'

class ScoreTest < ActiveSupport::TestCase

  describe 'timed' do

    it 'converts to normalized' do
      timed_score.to_normalized("2:41.6").must_equal (- (2 * 60 + 41 + 0.6) * 1_000)
    end

    it 'converts to raw' do
      timed_score.to_raw(-161600).must_equal "2:41.6"
    end

    it 'converts to normalized when time capped' do
      timed_score(time_cap: '1:00').to_normalized("C+1").must_equal -61_000
    end

    it 'converts to estimated normalized when time capped and rep count provided' do
      timed_score(time_cap: '1:00', reps: 10).to_est_normalized("C+1").must_equal -66_000
    end

    it 'converts to estimated normalized when time capped and rep breakdown provided' do
      timed_score(time_cap: '1:00', reps: [ [5, "10"], [1, "20"] ]).to_est_normalized("C+2").must_equal -90_000
    end

    it 'converts to raw when time capped' do
      timed_score(time_cap: '1:00').to_raw(-61_000).must_equal 'C+1'
    end

    it 'converts to estimated raw when time capped' do
      timed_score(time_cap: '1:00', reps: [ [5, "10"], [1, "20"] ]).to_est_raw(-90_000).must_equal '1:30'
    end

  end

  describe 'weights or reps' do

    it 'converts to normalized' do
      weight_or_reps_score.to_normalized("210").must_equal 210
    end

    it 'converts to raw' do
      weight_or_reps_score.to_raw(210).must_equal "210"
    end

  end

  private

  def timed_score(opts = {})
    event = Competition::Event.new({num: 1, name: '', scoring: 'time', opts: opts}.with_indifferent_access)
    Score.new(event)
  end

  def weight_or_reps_score
    event = Competition::Event.new({num: 1, name: '', scoring: 'weight'}.with_indifferent_access)
    Score.new(event)
  end

end