require 'net/http'
require 'cgi'
require 'openssl'
require 'rexml/document'

module GoogleApps
	class Transport
		attr_reader :request, :response
		attr_accessor :auth, :user, :group, :nickname

		def initialize(domain, targets = {})
			@auth = targets[:auth] || "https://www.google.com/accounts/ClientLogin"
			@user = targets[:user] || "https://apps-apis.google.com/a/feeds/#{domain}/user/2.0"
      @pubkey = targets[:pubkey] || "https://apps-apis.google.com/a/feeds/compliance/audit/publickey/#{domain}"
			@group = targets[:group]
			@nickname = targets[:nickname]
      @export = targets[:export] || "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/#{domain}"
			@token = nil
			@response = nil
			@request = nil
		end
		
		def authenticate(account, pass)
			uri = URI(@auth)
			@request = Net::HTTP::Post.new(uri.path)
			@request.body = auth_body(account, pass)
			set_headers :auth

			@response = request(uri)
			@response.body.split("\n").grep(/auth=(.*)/i)

			@token = $1
		end

		def auth_body(account, pass)
			"&Email=#{CGI::escape(account)}&Passwd=#{CGI::escape(pass)}&accountType=HOSTED&service=apps"
		end

    def request_export(username, document)
      uri = URI(@export + "/#{username}")
      @request = Net::HTTP::Post.new uri.path
      @request.body = document
      set_headers :user

      @response = request(uri)
    end

    def export_status(username, req_id)
      uri = URI(@export + "/#{username}/#{req_id}")
      @request = Net::HTTP::Get.new uri.path
      set_headers :user

      (@response = request(uri)).body
    end

    # TODO: Shouldn't rely on export_status being run first.  Self, this is lazy and stupid.
    def fetch_export(flename)
      doc = REXML::Document.new(@response.body)
      urls = []
      doc.elements.each('entry/apps:property') do |property|
        urls << property.attributes['value'] if property.attributes['name'].match 'fileUrl'
      end

      urls.each do |url|
        download(url, filename)
      end
    end

    def download(url, filename)
      uri = URI(url)
      @request = Net::HTTP::Get.new uri.path
      set_headers :user

      File.new(filename, "w") do |file|
        file.puts request(uri).body
      end
    end

		def add(endpoint, document)
			uri = URI(instance_variable_get("@#{endpoint.to_s}"))
			@request = Net::HTTP::Post.new(uri.path)
			@request.body = document
			set_headers :user

			@response = request(uri)
		end

    def update(endpoint, document)
    	# TODO: Username needs to come from somewhere for uri
      uri = URI(instance_variable_get("@#{endpoint.to_s}") + "/")
    end

    def delete(endpoint, id)
      uri = URI(instance_variable_get("@#{endpoint.to_s}") + "/#{id}")
      @request = Net::HTTP::Delete.new(uri.path)
      set_headers :user
      
      @response = request(uri)
    end

    def method_missing(name, *args)
    	super unless name.match /([a-z]*)_([a-z]*)/

      case $1
      when "new"
      	self.send(:add, $2, *args)
      when "delete"
        self.send(:delete, $2, *args)
      else
      	super
      end
    end


    private

    # TODO: Clashes with @request reader
		def request(uri)
			Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
				http.request(@request)
			end
		end

		def set_headers(request_type)
			if request_type.to_sym == :auth
				@request['content-type'] = "application/x-www-form-urlencoded"
			else
				@request['content-type'] = "application/atom+xml"
				@request['authorization'] = "GoogleLogin auth=#{@token}"
			end
		end
	end
end