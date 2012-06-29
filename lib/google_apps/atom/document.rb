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
    end
  end
end