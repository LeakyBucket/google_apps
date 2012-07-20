require 'net/http'

module GoogleApps
  class AppsRequest
    attr_reader :uri

    def initialize(verb, uri, headers)
      @uri = URI uri
      @ssl = (@uri.scheme == 'https')
      @http_request = initialize_http(verb)

      set_headers(headers)
    end


    # send_request does the actual work of sending @http_request as
    # it is currently constructed.
    #
    # send_request
    #
    # send_request returns a Net::HTTPResponse object.
    def send_request
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @ssl) do |http|
        http.request(@http_request)
      end
    end


    # add_body sets the body the provided content.
    #
    # add_body 'bob'
    #
    # add_body returns the content added.
    def add_body(content)
      @http_request.body = content
    end


    private


    # intialize_http builds the proper type of HTTP object for the
    # request.  It takes an HTTP verb as it's argument.
    #
    # initialize_http :get
    #
    # initialize_http returns a Net::HTTP object of the specified type.
    def initialize_http(verb)
      build_constant(verb.to_s).new(@uri.request_uri)
    end


    # build_constant returns the proper constant for the specified
    # http verb.  It takes a HTTP verb as it's argument.
    #
    # build_constant :get
    #
    # build_constant returns the constant corresponding to the Net::HTTP
    # class of the specified type.
    def build_constant(verb)
      "Net::HTTP::#{verb.capitalize}".split('::').inject(Object) do |context, constant|
        context.const_get constant
      end
    end


    # set_headers sets the headers on @http_request.  set_headers takes
    # an array of header/value pairs as it's only argument.
    #
    # set_headers [['content-type', 'application/xml']]
    def set_headers(headers)
      headers.each do |field, value|
        @http_request[field] = value
      end
    end
  end
end