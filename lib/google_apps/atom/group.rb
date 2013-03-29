class GoogleApps
  module Atom
    class Group < Document
      attr_accessor :id, :name, :description, :permissions

      MAP = {
        groupId: :id,
        groupName: :name,
        emailPermission: :permission,
        description: :description
      }

      def initialize(xml = nil)
        super(xml, MAP)
        xml ? attrs_from_props : @doc.root = build_root(:group)
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
      # new_group returns @doc.root
      def new_group(group_data)
        [:id, :name].each { |attr| raise(ArgumentError, "Missing or Invalid Parameter(s)") unless group_data.key?(attr) }
        set_values group_data
      end


      # set_values will add the specified group attributes
      # to @doc.  set_values accepts a hash with any of
      # the following keys:  id:, name:, description:, perms:
      #
      # set_values id: 'blah', description: 'Unexciting and uninspired'
      #
      # set_values returns @doc.root
      def set_values(group_values)
        group_values.keys.each do |key|
          prop = Atom::XML::Node.new('apps:property')
          prop_name(prop, key)
          prop.attributes['value'] = group_values[key]
          @doc.root << prop
        end

        @doc.root
      end


      def change_value(name, old_value, new_value)
        find_and_update '//apps:property', { name => [old_value, new_value] }
      end

      # TODO:  This needs to check all attributes of the element
      def id=(value)
        @id ? change_value(:value, @id, value) : set_values(id: value)

        @id = value
        @doc = parse(@doc)
      end


      def name=(value)
        @name ? change_value(:value, @name, value) : set_values(name: value)

        @name = value
        @doc = parse(@doc)
      end


      def permissions=(value)
        @permissions ? change_value(:value, @permissions, value) : set_values(perms: value)

        @permissions = value
        @doc = parse(@doc)
      end


      def description=(value)
        @description ? change_value(:value, @description, value) : set_values(description: value)

        @description = value
        @doc = parse(@doc)
      end


      # to_s returns @doc as a String.
      def to_s
        @doc.to_s
      end

      private


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