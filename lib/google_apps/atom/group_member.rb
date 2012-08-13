module GoogleApps
  module Atom
    class GroupMember
      include Atom::Node
      include Atom::Document

      attr_accessor :member, :type

      def initialize(xml = nil)
        if xml
          @document = parse(xml)
          populate_self
        else
          @document = Atom::XML::Document.new
          @document.root = build_root
        end
      end


      # member= sets the member value, if @member is non-nil
      # member= will replace the value in the XML document
      # before setting @member to the new value.
      #
      # member = 'test_user@cnm.edu'
      #
      # member= returns the value of @member
      def member=(member)
        @member.nil? ? add_node('memberId', member) : change_node('memberId', member)

        @document = parse(@document)
        @member = member
      end


      def type=(type)
        @type.nil? ? add_node('memberType', type) : change_node('memberType', type)

        @document = parse(@document)
        @type = type
      end
      

      # to_s returns @document as a string.
      def to_s
        @document.to_s
      end


      private

      # 
      # @param [] type
      # @param [] value
      # 
      # @visibility private
      # @return 
      def add_node(type, value)
        @document.root << create_node(type: 'apps:property', attrs: [['name', type], ['value', value]])
      end


      def change_node(type, value)
        @document.find('//apps:property').each do |node|
          node.attributes['value'] = value if node.attributes['name'] == type
        end
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


      # 
      # 
      # @visibility private
      # @return 
      def populate_self
        @document.find('//apps:property').each do |node|
          @member = node.attributes['value'] if node.attributes['name'] == 'memberId'
          @type = node.attributes['value'] if node.attributes['name'] == 'memberType'
        end
      end
    end
  end
end