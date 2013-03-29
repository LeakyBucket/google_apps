class GoogleApps
  module Atom
    class Document
      include Node

      @types = []

      #
      # @param [String] doc
      # @param [Hash] map
      #
      # @visibility public
      # @return
      def initialize(doc, map = {})
        @doc = doc.nil? ? new_empty_doc : parse(doc)
        @map = map
      end


      #
      # Document keeps track of all it's subclasses.  This makes
      # it easy to look up the document types supported by the
      # library.
      #
      # @param [Constant] subclass
      #
      # @visibility public
      # @return
      def self.inherited(subclass)
        self.add_type subclass
        Atom.add_doc_dispatcher self.sub_to_meth(subclass)
      end


      #
      # Change subclass constant into a valid method name.
      #
      # @param [Constant] subclass should be a class name
      #
      # @visibility public
      # @return
      def self.sub_to_meth(subclass)
        subclass.to_s.split('::').last.scan(/[A-Z][a-z0-9]+/).map(&:downcase).join('_')
      end


      #
      # Accessor for the Document types array.  This array is a
      # list of all subclasses of GoogleApps::Atom::Document
      #
      # @visibility public
      # @return
      def self.types
        @types
      end


      #
      # Adds a subclass to the @types array.
      #
      # @param [Constant] type
      #
      # @visibility public
      # @return
      def self.add_type(type)
        # TODO:  Need to convert from const to symbol before adding
        @types << type
      end


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


      # find_values searches @doc and assigns any values
      # to their corresponding instance variables.  This is
      # useful when we've been given a string of XML and need
      # internal consistency in the object.
      #
      # find_values
      def find_values
        @doc.root.each do |entry|
          intersect = @map.keys & entry.attributes.to_h.keys.map(&:to_sym)
          set_instances(intersect, entry) unless intersect.empty?
        end
      end


      # find_and_update updates the values for the specified
      # attributes on the node specified by the given xpath
      # value.  It is ill behaved and will change any
      # matching attributes in any node returned using the
      # given xpath.
      #
      # find_and_update takes an xpath value and a hash of
      # attribute names with current and new value pairs.
      #
      # find_and_update '/apps:nickname', name: ['Bob', 'Tom']
      def find_and_update(xpath, attributes)
        @doc.find(xpath).each do |node|
          if node_match?(node, attributes)
            attributes.each_key do |attrib|
              node.attributes[attrib.to_s] = attributes[attrib][1]
            end
          end
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
      def set_instances(intersect, node)
        intersect.each do |attribute|
          instance_variable_set "@#{@map[attribute]}", check_value(node.attributes[attribute])
        end
      end


      #
      #  Sets instance variables for property list type documents.
      #
      # @visibility public
      # @return
      def attrs_from_props
        @doc.find('//apps:property').each do |entry|
          prop_name = entry.attributes['name'].to_sym
          if @map.keys.include?(prop_name)
            instance_variable_set "@#{@map[prop_name]}", check_value(entry.attributes['value'])
          end
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
      def build_root(type)
        root = create_node(type: 'atom:entry')

        add_namespaces root, determine_namespaces(type)
        root << create_node(type: 'apps:category', attrs: Atom::CATEGORY[type.to_sym]) if Atom::CATEGORY[type.to_sym]

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
      def determine_namespaces(type)
        ns = { atom: Atom::NAMESPACES[:atom], apps: Atom::NAMESPACES[:apps] }

        case type.to_s
          when 'group', 'groupmember'
            ns[:gd] = Atom::NAMESPACES[:gd]
        end

        ns
      end


      #
      # Delete a node from the document
      #
      # @param [String] xpath is a node identifier in Xpath format
      # @param [Array] attrs is an array of attr, value pairs
      #
      # @visibility public
      # @return
      def delete_node(xpath, attrs)
        @doc.find(xpath).each do |node|
          node.remove! if node_match?(node, attrs)
        end
      end


      # Prints the contents of @doc
      #
      # @visibility public
      # @return
      def to_s
        @doc.to_s
      end
    end
  end
end