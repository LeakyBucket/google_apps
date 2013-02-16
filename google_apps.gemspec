Gem::Specification.new do |spec|
  spec.name = 'google_apps'
  spec.version = '0.5'
  spec.date = '2012-09-20'
  spec.license = "MIT"
  spec.summary = 'Google Apps APIs'
  spec.description = 'Library for interfacing with Google Apps\' Domain and Application APIs'
  spec.authors = ['Glen Holcomb']
  spec.add_dependency('libxml-ruby', '>= 2.2.2')
  spec.files = Dir.glob(File.join('**', 'lib', '**', '*.rb'))
  spec.homepage = 'https://github.com/LeakyBucket/google_apps'

  spec.add_development_dependency 'rspec'

  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
end
