require 'libxml'
require 'openssl'
require 'base64'

module GoogleApps
  module Atom
    include LibXML
    HASH_FUNCTION = "SHA-1"
  end
end