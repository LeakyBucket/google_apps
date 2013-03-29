class GoogleApps
  module Atom
    class MessageAttributes < Document
      attr_reader :labels
      attr_accessor :property

      DRAFT = 'IS_DRAFT'
      INBOX = 'IS_INBOX'
      SENT = 'IS_SENT'
      TRASH = 'IS_TRASH'
      STARRED = 'IS_STARRED'
      UNREAD = 'IS_UNREAD'

      def initialize(xml = nil)
        super(xml)

        if xml
          find_labels
          get_item_property
        else
          @labels = []
          set_header
        end
      end

      def add_property(prop)
        property = Atom::XML::Node.new 'apps:mailItemProperty'
        property['value'] = prop

        @doc.root << property
        @doc = parse(@doc)
      end

      def property=(value)
        @property.nil? ? add_property(value) : change_property(value)
      end

      def add_label(name)
        label = Atom::XML::Node.new 'apps:label'
        label['labelName'] = name

        @doc.root << label
        @labels << name
        @doc = parse(@doc)
      end

      def <<(value)
        add_label(value) unless @labels.include?(value)
      end

      def remove_label(value)
        @labels.delete(value)
        delete_node('//apps:label', labelName: [value])
      end

      def to_s
        @doc.to_s
      end

      private

      def set_header
        @doc.root = Atom::XML::Node.new 'atom:entry' # API Docs show just entry here

        Atom::XML::Namespace.new(@doc.root, 'atom', 'http://www.w3.org/2005/Atom') # API Docs show this as just xmlns
        Atom::XML::Namespace.new(@doc.root, 'apps', 'http://schemas.google.com/apps/2006')

        @doc.root << category
        @doc.root << content
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

      def find_labels
        @labels = @doc.find('//apps:label').inject([]) { |labels, entry| labels << entry.attributes['labelName']; labels }
      end

      def get_item_property
        @property = @doc.find('//apps:mailItemProperty').first.attributes['value']
      end
    end
  end
end