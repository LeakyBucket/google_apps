module GoogleApps
  module Atom
    class GroupMember
      attr_accessor :member

      def initialize
        @document = Atom::XML::Document.new
        add_header
      end

      def member=(member)
        @member.nil? ? set_member(member) : change_member(member)
      end

      def to_s
        @document.to_s
      end

      private

      def set_member(member)
        @document.root << build_node(member)

        @member = member
      end

      def build_node(member)
        node = Atom::XML::Node.new('apps:property')
        node.attributes['name'] = 'memberId'
        node.attributes['value'] = member

        node
      end

      def change_member(member)
        # This really should use find but I can't figure out how to
        # get the XPath to work with this document.
        @document.root.each do |node|
          node.attributes['value'] = member if node.attributes['value'] == @member
        end

        @member = member
      end

      def add_header
        @document.root = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
        Atom::XML::Namespace.new(@document.root, 'gd', 'http://schemas.google.com/g/2005')
      end
    end
  end
end