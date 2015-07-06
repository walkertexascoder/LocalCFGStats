module HomeHelper

  def year_select_options
    options_for_select((2011..Date.current.year).to_a.reverse)
  end

  def stage_select_options
    select_options_by_enum(HQ::Stage.all)
  end

  def division_select_options
    select_options_by_enum(HQ::Division.all)
  end

  def super_region_and_region_select_options
    super_regions = HQ::SuperRegion.all.map {|e| [e.name.titleize, e.name]}
    regions = HQ::Region.all.map {|e| [e.name.titleize, e.name]}

    grouped_options_for_select(
        'Super Region' => super_regions,
        'Region' => regions
    )
  end

  def region_select_options
    select_options_by_enum(HQ::Region.all)
  end

  def regional_event_select_options
    options = (1..7).map {|num| ["Event #{num}", num] }
    options_for_select(options)
  end

  def select_options_by_enum(enums)
    options = enums.map {|e| [e.name.titleize, e.name] }
    options_for_select(options)
  end

  def analyzed_year_select_options
    options_for_select([2015])
  end

  def scorer_options
    options_for_select([['Golf', 'golf'], ['2015 Regional', '2015_regional']])
  end

  def analyzed_super_region_select_options
    options = HQ::SuperRegion.map {|e| [e.name.titleize, e.name] }
    options.unshift(['Games Qualifiers', 'games_qualifier'])
    options.unshift(['Across Regions', 'overall'])
    options_for_select(options)
  end

end
