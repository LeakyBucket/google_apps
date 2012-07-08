module GoogleApps
  module Atom
    class Feed
      # TODO: Google's feed responses are inconsistent.  Will need special fun time, assholes.

      include Atom::Node
      include Atom::Document

      attr_reader :xml, :items, :next_page

      TYPE_MATCH = /<id.*(user|group|nickname).*?<\/id/
      #TYPE_MATCH = /term.*?\#(\w*?)/

      def initialize(xml)
        @xml = parse(xml)
        @items = entries_from document: @xml, type: @xml.to_s.match(TYPE_MATCH).captures[0], entry_tag: 'entry'
      end

      # TODO: Need to make sure this works for feeds other than user.
      def entries_from(properties)
        type = properties[:type].to_sym

        properties[:document].root.inject([]) do |results, entry|
          if entry.name == properties[:entry_tag]
            results << new_doc(type, node_to_ary(entry), ['apps:', 'atom:', 'gd:'])
          end
          set_next_page(entry) if entry.name == 'link' and entry.attributes[:rel] == 'next'
          results
        end
      end


      def set_next_page(node)
        @next_page = node.attributes[:href]
      end


      # node_to_ary converts a Atom::XML::Node to an array.
      #
      # node_to_ary node
      #
      # node_to_ary returns the string representation of the
      # given node split on \n.
      def node_to_ary(node)
        node.to_s.split("\n")
      end


      # new_doc creates a new Atom document from the data
      # provided in the feed.  new_doc takes a type, an
      # array of content to be placed into the document
      # as well as an array of filters.
      #
      # new_doc 'user', content_array, ['apps:']
      #
      # new_doc returns an GoogleApps::Atom document of the
      # specified type.
      def new_doc(type, content_array, filters)
        content_array = filters.inject([]) do |content, filter|
          content << grab_elements(content_array, filter)
          content
        end

        add_category content_array, type

        Atom.send type, entry_wrap(content_array.flatten).join("\n")
      end


      # add_category adds the proper atom:category node to the
      # content_array
      #
      # add_category content_array, 'user'
      #
      # add_category returns the modified content_array
      def add_category(content_array, type)
        content_array.unshift(create_node(type: 'atom:category', attrs: Atom::CATEGORY[type.to_sym]).to_s)
      end


      # grab_elements applies the specified filter to the
      # provided array.  Google's feed provides a lot of data
      # that we don't need in an entry document.
      #
      # grab_elements content_array, 'apps:'
      #
      # grab_elements returns an array of items from content_array
      # that match the given filter.
      def grab_elements(content_array, filter)
        content_array.grep(Regexp.new filter)
      end


      # entry_wrap adds atom:entry opening and closing tags
      # to the provided content_array and the beginning and
      # end.
      #
      # entry_wrap content_array
      #
      # entry_wrap returns an array with an opening atom:entry
      # element prepended to the front and a closing atom:entry
      # tag appended to the end.
      def entry_wrap(content_array)
        content_array.unshift(Atom::ENTRY_TAG[0]).push(Atom::ENTRY_TAG[1])
      end
    end
  end
end