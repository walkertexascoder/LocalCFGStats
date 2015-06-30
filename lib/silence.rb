module Silence

  def silence
    # what happened to ActiveRecord::Base.silence?
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    begin
      yield
    ensure
      ActiveRecord::Base.logger = old_logger
    end
  end

end