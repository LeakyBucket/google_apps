require 'net/http'

module GoogleApps
  class AppsRequest
    def initialize(verb, uri, headers)
      @uri = URI uri
      @ssl = (@uri.scheme == 'https')
      @http_request = initialize_http(verb)

      set_headers(headers)
    end
    
    def send_request
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @ssl) do |http|
        http.request(@http_request)
      end
    end

    def add_body(content)
      @http_request.body = content
    end


    private

    def initialize_http(verb)
      build_constant(verb.to_s).new(@uri.request_uri)
    end

    def build_constant(verb)
      "Net::HTTP::#{verb.capitalize}".split('::').inject(Object) do |context, constant|
        context.const_get constant
      end
    end

    def set_headers(headers)
      headers.each_key do |key|
        @http_request[key.to_s] = headers[key]
      end
    end
  end
end