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
    DOCUMENTS = %w(user export group group_member message_attributes public_key)

    # The idea is to make document distribution more dynamic.
    # Might be pointless but it's here for now.
    DOCUMENTS.each do |doc|
      eval "def #{doc}\n  #{doc.camel_up}.new\nend"
      module_function doc.to_sym
    end
  end
end