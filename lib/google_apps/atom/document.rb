module GoogleApps
  module Atom
    module Document
      # parse takes xml, either a document or a string
      # and returns a parsed document.  Since libxml-ruby
      # doesn't build a parse tree dynamically this
      # is needed more than you would think.
      #
      # parse xml
      #
      # parse returns a parsed xml document
      def parse(xml)
        document = make_document(xml)

        Atom::XML::Parser.document(document).parse
      end


      # make_document takes either an xml document or a
      # string and generates an xml document.
      #
      # make_document xml
      #
      # make_document returns an xml document.
      def make_document(xml)
        xml.is_a?(Atom::XML::Document) ? xml : Atom::XML::Document.string(xml)
      end


      # new_empty_doc creates an empty LibXML::XML::Document
      #
      # new_empty_doc
      #
      # new_empty_doc returns a LibXML::XML::Document without
      # any nodes.
      def new_empty_doc
        Atom::XML::Document.new
      end


      # find_values searches @document and assigns any values
      # to their corresponding instance variables.  This is
      # useful when we've been given a string of XML and need
      # internal consistency in the object.
      #
      # find_values
      def find_values # Moved from User and Group, causing segfault but only at odd times
        map_key = self.class.to_s.split(':').last.downcase.to_sym
        map = Atom::MAPS[map_key]

        @document.root.each do |entry|
          intersect = map.keys & entry.attributes.to_h.keys.map(&:to_sym)
          set_instances(intersect, entry, map) unless intersect.empty?
        end
      end


      # Sets instance variables in the current object based on 
      # values found in the XML document and the mapping specified
      # in GoogleApps::Atom::MAPS
      # 
      # @param [Array] intersect
      # @param [LibXML::XML::Node] node
      # @param [Hash] map
      # 
      # @visibility public
      # @return 
      def set_instances(intersect, node, map)
        intersect.each do |attribute|
          instance_variable_set "@#{map[attribute]}", check_value(node.attributes[attribute])
        end
      end


      # build_root creates the shared root structure for the
      # document.
      #
      # build_root
      #
      # build_root returns an atom:entry node with an
      # apps:category element appropriate for the document
      # type.
      def build_root
        root = create_node(type: 'atom:entry')

        add_namespaces root, determine_namespaces
        root << create_node(type: 'apps:category', attrs: Atom::CATEGORY[type_to_sym]) if Atom::CATEGORY[type_to_sym]

        root
      end


      # type_to_s returns the current document's type as a
      # string.
      #
      # type_to_s
      #
      # type_to_s returns a string
      def type_to_s
        self.class.to_s.split(':').last.downcase
      end


      # type_to_sym returns the current document's type as a
      # symbol.
      #
      # type_to_sym
      #
      # type_to_sym returns a symbol
      def type_to_sym
        type_to_s.to_sym
      end


      # determine_namespaces builds a hash of namespace key/value
      # pairs.
      #
      # determine_namespaces
      #
      # determine_namespaces returns a hash
      def determine_namespaces
        ns = { atom: Atom::NAMESPACES[:atom], apps: Atom::NAMESPACES[:apps] }

        case type_to_s
          when 'group', 'groupmember'
            ns[:gd] = Atom::NAMESPACES[:gd]
        end

        ns
      end
    end
  end
end