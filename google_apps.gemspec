Gem::Specification.new do |spec|
  spec.name = 'google_apps'
  spec.version = '0.9'
  spec.date = '2013-03-11'
  spec.license = "MIT"
  spec.summary = 'Google Apps APIs'
  spec.description = 'Library for interfacing with Google Apps\' Domain and Application APIs'
  spec.authors = ['Glen Holcomb', 'Will Read']
  spec.files = Dir.glob(File.join('**', 'lib', '**', '*.rb'))
  spec.homepage = 'https://github.com/LeakyBucket/google_apps'

  spec.add_dependency('libxml-ruby', '>= 2.2.2')
  spec.add_dependency('oauth')
  spec.add_dependency('rest-client')

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'

  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.test_files << 'Rakefile'
end
