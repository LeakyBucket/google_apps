class GoogleApps
  module Atom
    class PublicKey < Document
      attr_reader :doc

      def initialize
        super(nil)
        @doc.root = build_root :publickey
      end

      # new_key adds the actual key to the PublicKey
      # XML document.
      #
      # new_key 'key'
      #
      # new_key returns @doc.root
      def new_key(key)
        property = Atom::XML::Node.new('apps:property')
        property['name'] = 'publicKey'
        property['value'] = Base64.encode64 key

        @doc.root << property
      end

      # to_s returns @doc as a String
      def to_s
        @doc.to_s
      end
    end
  end
end
