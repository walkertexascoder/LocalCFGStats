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
      format.csv { send_data to_csv(results), filename: suggested_filename }
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

  def to_csv(results)
    events = results.first.second[:results].size

    CSV.generate do |csv|
      header = ['Name']
      events.times do |index|
        event = "Event #{index + 1}"
        header << "#{event} Result"
        header << "#{event} Rank"
        header << "#{event} Score"
      end
      csv << header

      results.each do |name, attrs|
        result_attrs = attrs[:results]

        csv_row = [name]
        result_attrs.each do |result|
          csv_row << result[:result]
          csv_row << result[:rank]
          csv_row << result[:score]
        end
        csv << csv_row
      end
    end
  end

end
