Gem::Specification.new do |ga|
  ga.name = 'google_apps'
  ga.version = '0.4.9.2'
  ga.date = '2012-08-13'
  ga.summary = 'Google Apps APIs'
  ga.description = 'Library for interfacing with Google Apps\' Domain and Application APIs'
  ga.authors = ['Glen Holcomb']
  ga.add_dependency('libxml-ruby', '>= 2.2.2')
  ga.files = Dir.glob(File.join('**', 'lib', '**', '*.rb'))
  ga.homepage = 'https://github.com/LeakyBucket/google_apps'
end
