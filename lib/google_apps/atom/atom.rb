require 'libxml'
require 'digest/sha1'
require 'base64'

module GoogleApps
  module Atom
    include LibXML
    HASH_FUNCTION = "SHA-1"
  end
end