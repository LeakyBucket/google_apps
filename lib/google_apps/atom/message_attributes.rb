module GoogleApps
  module Atom
    class MessageAttributes
      def initialize
        @document = Atom::XML::Document.new
        set_header
      end
      
      def add_property(prop)
        property = Atom::XML::Node.new 'apps:mailItemProperty'
        property['value'] = prop

        @document.root << property
      end

      def add_label(name)
        label = Atom::XML::Node.new 'apps:label'
        label['labelName'] = name

        @document.root << label
      end

      def to_s
        @document.to_s
      end

      private

      def set_header
        @document.root = Atom::XML::Node.new 'atom:entry' # API Docs show just entry here

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom') # API Docs show this as just xmlns
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')

        @document.root << category
        @document.root << content
      end

      def category
        header = Atom::XML::Node.new 'category'
        header['scheme'] = 'http://schemas.google.com/g/2005#kind'
        header['term'] = 'http://schemas.google.com/apps/2006#mailItem'

        header
      end

      def content
        header = Atom::XML::Node.new 'atom:content'
        Atom::XML::Namespace.new(header, 'atom', 'http://www.w3.org/2005/Atom')
        header['type'] = 'message/rfc822'

        header
      end
    end
  end
end