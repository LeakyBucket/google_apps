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

      # TODO: Need to make sure this works for feeds other than user.
      def entries_from(properties)
        type = properties[:type].downcase.match(/(\w*?)s$|$/).captures[0].to_sym
        #type = properties[:type]

        properties[:document].root.inject([]) do |results, entry|
          if entry.name == properties[:entry_tag]
            results << new_doc(type, node_to_ary(entry), ['apps:'])
          end
          results
        end
      end


      def node_to_ary(node)
        node.to_s.split("\n")
      end


      def new_doc(type, content_array, filters)
        content_array = filters.inject([]) do |content, filter|
          content << grab_elements(content_array, filter)
          content
        end

        Atom.send type, entry_wrap(content_array.flatten).join("\n")
      end


      def grab_elements(content_array, filter)
        content_array.grep(Regexp.new filter)
      end


      def entry_wrap(content_array)
        content_array.unshift(Atom::ENTRY_TAG[0]).push(Atom::ENTRY_TAG[1])
      end
    end
  end
end