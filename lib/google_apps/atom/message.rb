module GoogleApps
  module Atom
    class Message
      def initialize
        @document = Atom::XML::Document.new
      end
      
      def from(filename)
        message = File.read(filename)
        @document.root = Atom::XML::Node.new('apps:rfc822Msg', message)
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')

        @document
      end

      def to_s
        @document.to_s
      end
    end
  end
end