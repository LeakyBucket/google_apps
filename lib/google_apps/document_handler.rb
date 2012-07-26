module GoogleApps
  class DocumentHandler
    attr_accessor :format

    def initialize(args)
      set_format args[:format]
    end
    

    # doc_from_string creates a document of the specified format
    # from the given string.
    def doc_from_string(text)
      case @format
      when :atom, :xml
        Atom::XML::Document.string(text)
      end
    end


    # format= sets the format for the DocumentHandler
    def format=(format)
      set_format format
    end



    private


    # look_up_doc_types returns a list of document types the
    # library supports in the current format.
    def look_up_doc_types
      case @format
      when :atom, :xml
        Atom::DOCUMENTS
      end
    end


    # set_format Sets @format and @documents
    def set_format(format)
      @format = format
      @documents = look_up_doc_types
    end
  end
end