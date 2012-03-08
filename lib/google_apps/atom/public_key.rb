module GoogleApps
  module Atom
    class PublicKey
      def initialize
        @document = Atom::XML::Document.new
        add_header
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

      private

      def add_header
        @document.root = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
      end
    end
  end
end
