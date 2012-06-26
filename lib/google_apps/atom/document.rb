module GoogleApps
  module Atom
    module Document
      def parse(xml)
        document = make_document(xml)

        Atom::XML::Parser.document(document).parse
      end

      def make_document(xml)
        xml.is_a?(Atom::XML::Document) ? xml : Atom::XML::Document.string(xml)
      end
    end
  end
end