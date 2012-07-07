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


      # add_namespaces adds the specified namespaces to the
      # specified node.  namespaces should be a hash of name,
      # value pairs.
      #
      # add_namespaces node, atom: 'http://www.w3.org/2005/Atom', apps: 'http://schemas.google.com/apps/2006'
      #
      # add_namespaces returns the node with namespaces
      def add_namespaces(node, namespaces)
        namespaces.each_pair do |name, value|
          Atom::XML::Namespace.new node, name.to_s, value
        end

        node
      end


      # add_attributes adds the specified attributes to the
      # given node.  It takes a LibXML::XML::Node and an
      # array of name, value attribute pairs.
      #
      # add_attribute node, [['title', 'emperor'], ['name', 'Napoleon']]
      #
      # add_attribute returns the modified node.
      def add_attributes(node, attributes)
        attributes.each do |attribute|
          node.attributes[attribute[0]] = attribute[1]
        end

        node
      end


      # update_node updates the values for the specified
      # attributes on the node specified by the given xpath
      # value.  It is ill behaved and will change any
      # matching attributes in any node returned using the
      # given xpath.
      #
      # update_node takes a document (must be parsed), an
      # xpath value and a hash of attribute names with
      # current and new value pairs.
      #
      # update_node document, '/apps:nickname', name: ['Bob', 'Tom']
      def find_and_update(document, xpath, attributes)
        document.find(xpath).each do |node|
          attributes.each_key do |attrib|
            node.attributes[attrib.to_s] = attributes[attrib][1] if node.attributes[attrib.to_s].to_s == attributes[attrib][0].to_s
          end
        end
      end


      # get_content returns the content of the specified node.
      # If multiple nodes match the xpath value get_content
      # will return the content of the first occurance.
      #
      # get_content document, '//title'
      #
      # get_content returns the content of the node as a string.
      def get_content(document, xpath)
        document.find(xpath).first.content
      end
    end
  end
end