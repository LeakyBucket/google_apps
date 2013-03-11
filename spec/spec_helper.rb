require 'google_apps'
require 'webmock/rspec'
require 'yaml'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.dirname(__FILE__) + '/support/**/*.rb')].each { |f| require f }

#WebMock.allow_net_connect!
WebMock.disable_net_connect!

RSpec.configure do |config|
  #config.include FactoryGirl::Syntax::Methods
  #config.order = "random"
end

