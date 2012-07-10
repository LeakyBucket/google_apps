module GoogleApps
  module Atom
    class Group
      include Atom::Node
      include Atom::Document

      #ATTRIBUTES = %w(id name description perms).map(&:to_sym)

      def initialize(xml = nil)
        if xml
          @document = parse(xml)
        else
          @document = Atom::XML::Document.new
          add_header
        end
      end

      # new_group populates the Group XML document with
      # the provided values.  new_group accepts a hash
      # with the following keys:  id, name, description
      # and perms. id and name are required for a call
      # to new_group.
      #
      # new_group id: 'ID', name: 'Name', description: 'Group Description',
      #           perms: 'emailPermissions'
      #
      # new_group returns @document.root
      def new_group(group_data)
        [:id, :name].each { |attr| raise(ArgumentError, "Missing or Invalid Parameter(s)") unless group_data.key?(attr) }
        set_values group_data
      end


      # set_values will add the specified group attributes
      # to @document.  set_values accepts a hash with any of
      # the following keys:  id:, name:, description:, perms:
      #
      # set_values id: 'blah', description: 'Unexciting and uninspired'
      #
      # set_values returns @document.root
      def set_values(group_values)
        group_values.keys.each do |key|
          prop = Atom::XML::Node.new('apps:property')
          prop_name(prop, key)
          prop.attributes['value'] = group_values[key]
          @document.root << prop
        end

        @document.root
      end

      # to_s returns @document as a String.
      def to_s
        @document.to_s
      end

      private

      # add_header sets the required boilerplate for a
      # Google Apps group.
      def add_header
        @document.root = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
        Atom::XML::Namespace.new(@document.root, 'gd', 'http://schemas.google.com/g/2005')
      end


      def check_value(value)
        case value
          when 'true'
            true
          when 'false'
            false
          else
            value
        end
      end


      # prop_name takes a LibXML::XML::Node object and
      # sets the name attribute based on the provided
      # key.
      #
      # prop_name returns the modified LibXML::XML::Node
      def prop_name(property, key)
        case key
        when :id
          property.attributes['name'] = 'groupId'
        when :name
          property.attributes['name'] = 'groupName'
        when :description
          property.attributes['name'] = 'description'
        when :perms
          property.attributes['name'] = 'emailPermissions'
        end

        property
      end
    end
  end
end