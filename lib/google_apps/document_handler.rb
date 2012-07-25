module GoogleApps
  class DocumentHandler
    attr_reader :format

    def initialize(args)
      @format = args[:format]
    end
    
    def doc_from_string(text)
      
    end
  end
end