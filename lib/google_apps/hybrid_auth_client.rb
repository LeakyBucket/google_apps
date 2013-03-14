require 'cgi'
require 'openssl'
require 'rexml/document'

module GoogleApps
  class HybridAuthClient
    include GoogleApps::Client

    def initialize(options)
      @domain = options[:domain]
      @google_app_id = options[:google_app_id]
      @google_app_secret = options[:google_app_secret]

      @user = "#{FEEDS_ROOT}/#{@domain}/user/2.0"
      @pubkey = "#{FEEDS_ROOT}/compliance/audit/publickey/#{@domain}"
      @migration = "#{FEEDS_ROOT}/migration/2.0/#{@domain}"
      @group = "#{FEEDS_ROOT}/group/2.0/#{@domain}"
      @nickname = "#{FEEDS_ROOT}/#{@domain}/nickname/2.0"
      audit_root = "#{FEEDS_ROOT}/compliance/audit/mail"
      @export = "#{audit_root}/export/#{@domain}"
      @monitor = "#{audit_root}/monitor/#{@domain}"

      @doc_handler = DocumentHandler.new
    end

    def headers
      {
          'content-type' => 'application/atom+xml',
          'Authorization' => "OAuth #{@token}"
      }
    end

    attr_accessor :version

    #def self.get(base, query_parameters, version = '2.0')
    #  response_body = make_request(:get, url(base, query_parameters), version)
    #  REXML::Document.new(response_body)
    #end
    #
    #def self.make_request(method, url, version)
    #  oauth_consumer = OAuth::Consumer.new(GOOGLE_APP_ID, GOOGLE_APP_SECRET)
    #  access_token = OAuth::AccessToken.new(oauth_consumer)
    #
    #  response = access_token.request(method, url, {'GData-Version' => version})
    #  if response.is_a?(Net::HTTPFound)
    #    return make_request(method, response['Location'], version)
    #  end
    #  throw :halt, [500, "Unable to query feed"] unless response.is_a?(Net::HTTPSuccess)
    #
    #  response.body
    #end

    private

    def self.url(base, query_parameters={})
      url = base
      unless query_parameters.empty?
        url += '?'
        query_parameters.each { |key, value| url += "#{CGI::escape(key)}=#{CGI::escape(value)}&" }
        url.chop!
      end
      url
    end
  end
end