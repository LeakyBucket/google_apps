module GoogleApps
  class DocumentHandler
    attr_accessor :format

    def initialize(args)
      set_format args[:format]
    end
    

    # create_doc creates a document of the specified format
    # from the given string.
    def create_doc(text, type = nil)
      @documents.include?(type) ? doc_of_type(text, type) : unknown_type(text)
    end


    # unknown_type takes a string and returns a document of
    # of the corresponding @format.
    def unknown_type(text)
      case @format
      when :atom, :xml
        Atom::XML::Document.string(text)
      end
    end


    # format= sets the format for the DocumentHandler
    def format=(format)
      set_format format
    end


    # doc_of_type takes a document type and a string and
    # returns a document of that type in the current format.
    def doc_of_type(text, type)
      raise "No #{@format.to_s.capitalize} document of type: #{type}" unless @documents.include?(type.to_s)

      case @format
      when :atom, :xml
        GoogleApps::Atom.send(type, text)
      end
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