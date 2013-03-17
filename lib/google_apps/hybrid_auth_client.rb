require 'oauth'

module GoogleApps
  class HybridAuthClient
    include GoogleApps::Client

    def initialize(options)
      @domain = options[:domain]
      @google_app_id = options[:google_app_id]
      @google_app_secret = options[:google_app_secret]
    end

    def make_request(method, url, options = {})
      version = options[:version] || '2.0'
      headers = {'GData-Version' => version}.merge(options[:headers] || {})
      oauth_consumer = OAuth::Consumer.new(@google_app_id, @google_app_secret)
      access_token = OAuth::AccessToken.new(oauth_consumer)

      if [:get, :delete].include?(method)
        response = access_token.send(method, url, headers)
      else
        response = access_token.send(method, url, options[:body], headers)
      end
      throw :halt, [500, "Unable to query feed"] unless response.is_a?(Net::HTTPSuccess)

      response
    end
  end
end