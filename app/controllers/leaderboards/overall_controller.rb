require 'csv'
require 'hq/results'

class Leaderboards::OverallController < ApplicationController

  def create
    leaderboard = Leaderboards::Overall.new(results, scorer)

    respond_to do |format|
      format.csv { send_data leaderboard.to_csv, filename: suggested_filename }
    end
  end

  private

  def results
    # always categorizing by these...
    results = Result.tagged(year: year, division: division_id, stage: stage_id)

    if fictional?
      results = results.fictional
    end

    if ! cross_region? && ! games_qualifier?
      if region_id.present?
        results = results.region(region_id)
      elsif super_region_id.present?
        results = results.super_region(super_region_id)
      end
    end

    if games_qualifier?
      results = results.games_qualifier
    else
      results = results.not_games_qualifier
    end

    results
  end

  def suggested_filename
    parts = [year, stage_id, division_id]

    if cross_region?
      parts << 'all'
    else
      parts += [region_id, super_region_id]
    end

    if games_qualifier?
      parts << 'qualified'
    end

    parts << scorer

    parts.reject(&:blank?).join('_') + ".csv"
  end

  def scorer
    params[:scorer] || '2015_regional'
  end

  def year
    params[:year].to_i
  end

  def division_id
    params[:division]
  end

  def stage_id
    params[:stage]
  end

  def fictional?
    cross_region? || games_qualifier?
  end

  def cross_region?
    params[:region] == 'overall'
  end

  def games_qualifier?
    params[:region] == 'games_qualifier'
  end

  def region_id
    if (stage_id == 'regional' && year < 2015) || stage_id == 'open'
      params[:region]
    end
  end

  def super_region_id
    if stage_id == 'regional' && year >= 2015
      params[:region]
    end
  end

end
