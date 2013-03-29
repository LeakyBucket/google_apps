

class String
  def camel_up
    self.split('_').map(&:capitalize).join('')
  end
end

module GoogleApps
  module Atom
    include LibXML

    HASH_FUNCTION = "SHA-1"

    NAMESPACES = {
      atom: 'http://www.w3.org/2005/Atom',
      apps: 'http://schemas.google.com/apps/2006',
      gd: 'http://schemas.google.com/g/2005',
      openSearch: 'http://a9.com/-/spec/opensearchrss/1.0/'
    }

    CATEGORY = {
      user: [['scheme', 'http://schemas.google.com/g/2005#kind'], ['term', 'http://schemas.google.com/apps/2006#user']],
      nickname: [['scheme', 'http://schemas.google.com/g/2005#kind'], ['term', 'http://schemas.google.com/apps/2006#nickname']]
      #group: [['scheme', 'http://schemas.google.com/g/2005#kind'], ['term', 'http://schemas.google.com/apps/2006#group']]
    }

    ENTRY_TAG = ["<atom:entry xmlns:atom=\"#{NAMESPACES[:atom]}\" xmlns:apps=\"#{NAMESPACES[:apps]}\" xmlns:gd=\"#{NAMESPACES[:gd]}\">", '</atom:entry>']

    # Adds a Module Function that creates a corresponding document.
    # This allows for a centralized location for document creation.
    #
    # @param [String] type should correspond to the class name
    #
    # @visibility public
    # @return
    def add_doc_dispatcher(type)
      eval "def #{type}(*args)\n  #{type.camel_up}.new *args\nend" # Needs __file__ and __line__
      module_function type.to_sym
    end

    module_function :add_doc_dispatcher
  end
end