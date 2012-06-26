module GoogleApps
  module Atom
    class Feed
      include Atom::Node
      include Atom::Document

      attr_reader :xml, :items

      TYPE_MATCH = /<title type="text">(\w*?)</

      def initialize(xml)
        @xml = parse(xml)
        @items = entries_from document: @xml, type: @xml.to_s.match(TYPE_MATCH).captures[0], entry_tag: 'entry'
      end

      def entries_from(properties)
        type = properties[:type].downcase.match(/(\w*?)s$|$/).captures[0].to_sym

        properties[:document].root.inject([]) do |results, entry|
          results << Atom.send(type, entry) if entry.name == properties[:entry_tag]
          results
        end
      end
    end
  end
end