class GoogleApps
  class Template
    def self.render(path, binding)
      template = File.open(File.join(File.dirname(__FILE__), 'templates', path)).read
      Haml::Engine.new(template, format: :xhtml).render(binding)
    end
  end
end