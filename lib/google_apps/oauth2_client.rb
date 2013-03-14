require 'cgi'
require 'openssl'
require 'rexml/document'
require 'net/http'
require 'httparty'

module GoogleApps
  class Oauth2Client
    include HTTParty
    include GoogleApps::Client

    def initialize(options)
      @token = options[:token]
      @refresh_token = options[:refresh_token]
      @token_changed_callback = options[:token_changed_callback]

      set_initial_values(options[:domain])
    end

    private

    def get(endpoint, id = nil)
      id ? uri = URI(endpoint + build_id(id)) : uri = URI(endpoint)
      self.class.get(uri.to_s, headers: headers)
    end

    def post(url, document, migration_headers = nil)
      self.class.post(url, body: document.to_s, headers: migration_headers || headers)
    end

    def delete(endpoint, id)
      uri = URI(endpoint + "/#{id}")
      self.class.delete(uri.to_s, headers: headers)
    end

    def put(endpoint, target, document)
      uri = URI(endpoint + "/#{target}")
      self.class.put(uri.to_s, body: document.to_s, headers: headers)
    end

    def headers
      {
          'content-type' => 'application/atom+xml',
          'Authorization' => "OAuth #{@token}"
      }
    end
  end
end