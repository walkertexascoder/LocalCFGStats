ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/spec'
require 'minitest/rails'
require 'factory_girl'
require 'mocha/setup'
require 'webmock'
require 'vcr'

reporter_options = { color: true }
MiniTest::Reporters.use! [MiniTest::Reporters::DefaultReporter.new(reporter_options)]

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods

end

class MiniTest::Spec

  include FactoryGirl::Syntax::Methods

end