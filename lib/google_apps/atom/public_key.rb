module GoogleApps
  module Atom
    class PublicKey
      include Atom::Node
      include Atom::Document

      def initialize
        @document = Atom::XML::Document.new
        @document.root = build_root
      end
      
      # new_key adds the actual key to the PublicKey
      # XML document.
      #
      # new_key 'key'
      #
      # new_key returns @document.root
      def new_key(key)
        property = Atom::XML::Node.new('apps:property')
        property['name'] = 'publicKey'
        property['value'] = Base64.encode64 key

        @document.root << property
      end

      # to_s returns @document as a String
      def to_s
        @document.to_s
      end
    end
  end
end
