require 'google_apps'
require 'yaml'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path(File.dirname(__FILE__) + '/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  #config.include FactoryGirl::Syntax::Methods
  #config.order = "random"
end

