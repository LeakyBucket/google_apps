module GoogleApps
  module Atom
    class GroupOwner < Document
      attr_reader :address

      def initialize(xml = nil)
        super(xml)
        xml ? attrs_from_props : @doc.root = build_root(:group)
      end


      #
      # @param [String] address email address of the owner object.
      #
      # @visibility public
      # @return
      def add_address(address)
        add_prop_node('email', address)
        @doc = parse @doc
      end


      def update_address(address)
        find_and_update '//apps:property', value: [@address, address]
        @doc = parse @doc
      end


      #
      # @param [String] value Email address for the owner object
      #
      # @visibility public
      # @return
      def address=(value)
        @address ? update_address(value) : add_address(value)

        @address = value
      end
    end
  end
end