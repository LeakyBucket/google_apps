module GoogleApps
  module Atom
    class Feed
      include Atom::Node
      include Atom::Document

      attr_reader :xml, :items

      TYPE_MATCH = /<title type="text">(\w*?)</
      #TYPE_MATCH = /term.*?\#(\w*?)/

      def initialize(xml)
        @xml = parse(xml)
        @items = entries_from document: @xml, type: @xml.to_s.match(TYPE_MATCH).captures[0], entry_tag: 'entry'
      end

      # TODO: This fucking stinks like no ones business.
      def entries_from(properties)
        type = properties[:type].downcase.match(/(\w*?)s$|$/).captures[0].to_sym
        #type = properties[:type]

        properties[:document].root.inject([]) do |results, entry|
          if entry.name == properties[:entry_tag]
            doc = Atom.send type
            doc.document.root = create_node type: 'apps:entry'
            add_namespaces doc.document.root, atom: 'http://www.w3.org/2005/Atom', apps: 'http://schemas.google.com/apps/2006'
            entry.children.each do |child|
              doc.document.root << doc.document.import(child)
            end
            results << doc
          end
          #results << Atom.send(type, entry) if entry.name == properties[:entry_tag]
          results
        end
      end
    end
  end
end