class GoogleApps
  class Oauth2Client
    include GoogleApps::Client

    def initialize(options)
      @token = options[:token]
      @domain = options[:domain]
    end

    def make_request(method, url, options = {})
      headers = oauth_header.merge(options.delete(:headers) || {})
      if [:get, :delete].include?(method)
        RestClient.send(method, url, headers)
      else
        RestClient.send(method, url, options[:body], headers)
      end
    end

    private

    def oauth_header
      { 'Authorization' => "OAuth #{@token}" }
    end
  end
end