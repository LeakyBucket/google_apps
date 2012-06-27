require 'libxml'
require 'openssl'
require 'base64'

class String
  def camel_up
    self.split('_').map(&:capitalize).join('')
  end
end

module GoogleApps
  module Atom
    include LibXML

    HASH_FUNCTION = "SHA-1"
    DOCUMENTS = %w(user export group group_member message_attributes public_key feed)

    NAMESPACES = {
      atom: 'http://www.w3.org/2005/Atom',
      apps: 'http://schemas.google.com/apps/2006',
      gd: 'http://schemas.google.com/g/2005',
      openSearch: 'http://a9.com/-/spec/opensearchrss/1.0/'
    }

    # The idea is to make document distribution more dynamic.
    # Might be pointless but it's here for now.
    DOCUMENTS.each do |doc|
      eval "def #{doc}(*args)\n  #{doc.camel_up}.new *args\nend" # Needs __file__ and __line__
      module_function doc.to_sym
    end
  end
end