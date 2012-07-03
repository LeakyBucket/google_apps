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
            doc = new_doc_with_entry type
            entry.children.each do |child|
              doc.document.root << doc.document.import(child)
            end
            results << doc
          end
          #results << Atom.send(type, entry) if entry.name == properties[:entry_tag]
          results
        end
      end

      def new_doc_with_entry(type)
        Atom.send type, "<apps:entry xmlns:atom=\"#{Atom::NAMESPACES[:atom]}\" xmlns:apps=\"#{Atom::NAMESPACES[:apps]}\"/>"
      end
    end
  end
end