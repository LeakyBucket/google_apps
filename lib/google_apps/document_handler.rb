module GoogleApps
  class DocumentHandler
    def initialize
      @documents = look_up_doc_types
    end

    # create_doc creates a document of the specified format
    # from the given string.
    def create_doc(text, type = nil)
      @documents.include?(type) ? doc_of_type(text, type) : unknown_type(text)
    end

    # unknown_type takes a string and returns a document of
    # of the corresponding @format.
    def unknown_type(text)
      Atom::XML::Document.string(text)
    end

    # doc_of_type takes a document type and a string and
    # returns a document of that type in the current format.
    def doc_of_type(text, type)
      raise "No Atom document of type: #{type}" unless @documents.include?(type.to_s)

      GoogleApps::Atom.send(type, text)
    end

    private

    # look_up_doc_types returns a list of document types the
    # library supports in the current format.
    def look_up_doc_types
      Atom::Document.types.map { |subclass| sub_to_meth(subclass) }
    end

    def sub_to_meth(subclass) # TODO: This shouldn't be both here and in GoogleApps::Atom::Document
      subclass.to_s.split('::').last.scan(/[A-Z][a-z0-9]+/).map(&:downcase).join('_')
    end
  end
end