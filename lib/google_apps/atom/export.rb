module GoogleApps
  module Atom
    class Export
      include Atom::Node
      include Atom::Document

      HEADER = 'HEADER_ONLY'
      FULL = 'FULL_MESSAGE'

      def initialize(xml = nil)
        @document = Atom::XML::Document.new
        @document.root = build_root
      end

      # to_s returns @document as a string.
      def to_s
        @document.to_s
      end
      
      # start_date specifies a start date for the extract.  
      # Matching results that occurred before this date will
      # not be included in the result set.  start_date takes
      # a string as an argument, the format is as follows:
      #
      # 'yyyy-MM-dd HH:mm' where yyyy is the four digit year,
      # MM is the two digit month, dd is the two digit day,
      # HH is the hour of the day 0-23 and mm is the minute
      # 0-59
      #
      # start_date '2012-01-01 00:00'
      #
      # start_date returns @document.root
      def start_date(date)
        add_prop('beginDate', date)
      end

      # end_date specifies an end date for the extract.  
      # Matching results that occurred past this date will
      # not be included in the result set.  end_date takes
      # a string as an argument, the format is as follows:
      #
      # 'yyyy-MM-dd HH:mm' where yyyy is the four digit year,
      # MM is the two digit month, dd is the two digit day,
      # HH is the hour of the day 0-23 and mm is the minute
      # 0-59
      #
      # end_date '2012-01-01 08:30'
      #
      # end_date returns @document.root
      def end_date(date)
        add_prop('endDate', date)
      end

      # include_deleted will specify that matches which
      # have been deleted should be returned as well.  
      # The default is to omit deleted matches.
      #
      # include_deleted
      #
      # include_deleted returns @document.root
      def include_deleted
        add_prop('includeDeleted', 'true')
      end

      # query specifies a query string to be used when
      # filtering the messages to be returned.  You can
      # use any string that you could use in Google's
      # Advanced Search interface.
      #
      # query 'from: Bob'
      #
      # query returns @document.root
      def query(query_string)
        add_prop('searchQuery', query_string)
      end

      # content specifies the data to be returned in the
      # mailbox export.  There are two valid arguments: 
      # 'FULL_MESSAGE' or 'HEADER_ONLY'
      #
      # content 'HEADER_ONLY'
      #
      # content returns @document.root
      def content(type)
        add_prop('packageContent', type)
      end

      
      private

      # set_header adds the appropriate XML boilerplate for
      # a mailbox extract as specified by the GoogleApps
      # Email Audit API.
      def set_header
        @document.root = Atom::XML::Node.new 'atom:entry'

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')
      end

      # add_prop adds an element of the type: apps:property
      # to the extract document.
      def add_prop(name, value)
        prop = Atom::XML::Node.new('apps:property')
        prop['name'] = name
        prop['value'] = value

        @document.root << prop
      end
    end
  end
end