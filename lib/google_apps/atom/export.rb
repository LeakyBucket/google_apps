module GoogleApps
  module Atom
    class Export
      def initialize
        @document = Atom::XML::Document.new
        set_header
      end

      def to_s
        @document.to_s
      end
      
      def start_date(date)
        add_prop('beginDate', date)
      end

      def end_date(date)
        add_prop('endDate', date)
      end

      def search_deleted(flag)
        add_prop('includeDeleted', (flag ? 'true' : 'false'))
      end

      def query(query_string)
        add_prop('searchQuery', query_string)
      end

      def content(type)
        add_prop('packageContent', type)
      end

      
      private

      def set_header
        @document.root = Atom::XML::Node.new 'atom:entry'

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
      end

      def add_prop(name, value)
        prop = Atom::XML::Node.new('apps:property')
        prop['name'] = name
        prop['value'] = value

        @document.root << prop
      end
    end
  end
end