module GoogleApps
  module Atom
    class GroupMember
      include Atom::Node
      include Atom::Document

      attr_accessor :member

      def initialize
        @document = Atom::XML::Document.new
        @document.root = build_root
      end


      # member= sets the member value, if @member is non-nil
      # member= will replace the value in the XML document
      # before setting @member to the new value.
      #
      # member = 'test_user@cnm.edu'
      #
      # member= returns the value of @member
      def member=(member)
        @member.nil? ? set_member(member) : change_member(member)
      end


      # to_s returns @document as a string.
      def to_s
        @document.to_s
      end


      private

      # set_member adds a memberId property element to
      # the XML document and sets @member to the given
      # value.
      #
      # set_member 'test_user@cnm.edu'
      #
      # set_member returns the value of @member
      def set_member(member)
        @document.root << create_node(type: 'apps:property', attrs: [['name', 'memberId'], ['value', member]])

        @member = member
      end


      # change_member changes the value attribute of the
      # apps:property element in @document to the value
      # of the provided argument.  It also sets @member
      # to the provided argument.
      #
      # change_member 'test_user@cnm.edu'
      #
      # change_member returns the value of @member
      def change_member(member)
        # This really should use find but I can't figure out how to
        # get the XPath to work with this document.
        @document.root.each do |node|
          node.attributes['value'] = member if node.attributes['value'] == @member
        end

        @member = member
      end

      # parse_doc parses the current @document so that it can
      # be searched with find.
      def parse_doc(document = @document)
        Atom::XML::Parser.document(document).parse
      end
    end
  end
end