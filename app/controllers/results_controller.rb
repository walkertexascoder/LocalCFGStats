require 'csv'
require 'hq/results'

class ResultsController < ApplicationController

  def create
    results = HQ::Results.get(
      year: year,
      division: division_id,
      region: region_id,
      stage: stage_id
    )

    respond_to do |format|
      format.csv { send_data results.to_csv, filename: suggested_filename }
    end

  end

  private

  def suggested_filename
    parts = [year, stage_id, division_id]
    if stage_id != 'games'
      parts << region_id
    end
    parts.join('_') + ".csv"
  end

  def year
    params[:year]
  end

  def division_id
    params[:division]
  end

  def stage_id
    params[:stage]
  end

  def region_id
    params[:region]
  end

end
