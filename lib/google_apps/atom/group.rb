module GoogleApps
  module Atom
    class Group
      def initialize
        @document = Atom::XML::Document.new
        add_header
      end
      
      def new_group(group_data)
        group_data.keys.each do |key|
          prop = Atom::XML::Node.new('apps:property')
          prop_name(prop, key)
          prop.attributes['value'] = group_data[key]
          @document.root << prop 
        end
      end

      def to_s
        @document.to_s
      end

      private

      def add_header
        @document.root = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
        Atom::XML::Namespace.new(@document.root, 'gd', 'http://schemas.google.com/g/2005')
      end

      def prop_name(property, key)
        case key
        when :id
          property.attributes['name'] = 'groupId'
        when :name
          property.attributes['name'] = 'groupName'
        when :description
          property.attributes['name'] = 'description'
        when :perms
          property.attributes['name'] = 'emailPermission'
        end

        property
      end
    end
  end
end