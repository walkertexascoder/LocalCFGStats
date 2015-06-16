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

  def region_select_options
    super_regions = HQ::SuperRegion.all.map {|e| [e.name.titleize, e.name]}
    regions = HQ::Region.all.map {|e| [e.name.titleize, e.name]}

    grouped_options_for_select(
        'Super Region' => super_regions,
        'Region' => regions
    )
  end

  def select_options_by_enum(enums)
    options = enums.map {|e| [e.name.titleize, e.name] }
    options_for_select(options)
  end

end
