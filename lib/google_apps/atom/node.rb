module GoogleApps
  module Atom
    module Node

      # create_node takes a hash of properties from which to
      # build the XML node.  The properties hash must have
      # a :type key, it is also possible to pass an :attrs
      # key with an array of attribute name, value pairs.
      #
      # create_node type: 'apps:property', attrs: [['name', 'Tim'], ['userName', 'tim@bob.com']]
      #
      # create_node returns an Atom::XML::Node with the specified
      # properties.
      def create_node(properties)
        if properties[:attrs]
          add_attributes Atom::XML::Node.new(properties[:type]), properties[:attrs]
        else
          Atom::XML::Node.new properties[:type]
        end
      end

      def add_attributes(node, attributes)
        attributes.each do |attribute|
          node.attributes[attribute[0]] = attribute[1]
        end

        node
      end

      def update_node(*properties)
        @document.root.each do |node|
          node.attributes[]
        end
      end
    end
  end
end