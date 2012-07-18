require 'net/http'
require 'cgi'
require 'openssl'
require 'rexml/document'

module GoogleApps
  class Transport
    attr_reader :request, :response, :domain, :feeds
    attr_accessor :auth, :user, :group, :nickname, :export

    BOUNDARY = "=AaB03xDFHT8xgg"
    PAGE_SIZE = {
      user: 100,
      group: 200
    }

    def initialize(domain, targets = {})
      @auth = targets[:auth] || "https://www.google.com/accounts/ClientLogin"
      @user = targets[:user] || "https://apps-apis.google.com/a/feeds/#{domain}/user/2.0"
      @pubkey = targets[:pubkey] || "https://apps-apis.google.com/a/feeds/compliance/audit/publickey/#{domain}"
      @migration = targets[:migration] || "https://apps-apis.google.com/a/feeds/migration/2.0/#{domain}"
      @group = targets[:group] || "https://apps-apis.google.com/a/feeds/group/2.0/#{domain}"
      @nickname = targets[:nickname] || "https://apps-apis.google.com/a/feeds/#{domain}/nickname/2.0"
      @export = targets[:export] || "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/#{domain}"
      @domain = domain
      @token = nil
      @response = nil
      @request = nil
      @feeds = []
    end


    # authenticate will take the provided account and
    # password and attempt to authenticate them with
    # Google
    #
    # authenticate 'username@domain', 'password'
    #
    # authenticate returns the HTTP response received
    # from Google
    def authenticate(account, pass)
      uri = URI(@auth)
      @request = Net::HTTP::Post.new(uri.path)
      @request.body = auth_body(account, pass)
      set_headers :auth

      @response = request uri

      set_auth_token

      @response
    end

    # request_export performs the GoogleApps API call to
    # generate a mailbox export.  It takes the username
    # and an GoogleApps::Atom::Export instance as
    # arguments
    #
    # request_export 'username', document
    #
    # request_export returns the HTTP response received
    # from Google.
    def request_export(username, document)
      add(@export + "/#{username}", document)
    end

    # export_status checks the status of a mailbox export
    # request.  It takes the username and the request_id
    # as arguments
    #
    # export_status 'username', 847576
    #
    # export_status will return the status of the HTTP
    # response from Google
    def export_status(username, req_id)
      get(@export + "/#{username}", req_id)
    end

    def fetch_export(username, req_id, filename) # :nodoc:
      # TODO: Shouldn't rely on export_status being run first.  Self, this is lazy and stupid.
      export_status(username, req_id)
      doc = REXML::Document.new(@response.body)
      urls = []
      doc.elements.each('entry/apps:property') do |property|
        urls << property.attributes['value'] if property.attributes['name'].match 'fileUrl'
      end

      urls.each do |url|
        download(url, filename + "#{urls.index(url)}")
      end
    end

    # download makes a get request of the provided url
    # and writes the body to the provided filename.
    #
    # download 'url', 'save_file'
    def download(url, filename)
      uri = URI(url)
      @request = Net::HTTP::Get.new uri.path
      set_headers :user

      File.open(filename, "w") do |file|
        file.puts request(uri).body
      end
    end

    # get is a generic target for method_missing.  It is
    # intended to handle the general case of retrieving a
    # record from the Google Apps Domain.  It takes an API
    # endpoint and an id as arguments.
    #
    # get 'endpoint', 'username'
    #
    # get returns the HTTP response received from Google.
    def get(endpoint, id = nil)
      # TODO:  Need to handle <link rel='next' for pagination if wanting all users
      id ? uri = URI(endpoint + build_id(id)) : uri = URI(endpoint)
      @request = Net::HTTP::Get.new(uri.request_uri)
      set_headers :user

      @response = request uri
    end


    # get_users retrieves as many users as specified from the
    # domain.  If no starting point is given it will grab all the
    # users in the domain.  If a starting point is specified all
    # users from that point on (alphabetically) will be returned.
    #
    # get_users start: 'lholcomb2'
    #
    # get_users returns the final response from google.
    def get_users(options = {})
      get_all :users, options
    end


    # get_groups retrieves all the groups from the domain
    #
    # get_groups
    #
    # get_groups returns the final response from Google.
    def get_groups(options = {})
      get_all :groups, options
    end


    # get_all retrieves a batch of records of the specified type
    # from google.  You must specify the type of object you want
    # to retreive.  You can also specify a start point and a limit.
    #
    # get_all 'users', start: 'lholcomb2', limit: 300
    #
    # get_all returns the HTTP response received from Google.
    def get_all(type, options = {})
      @feeds, page = [], 0
      type = normalize_type type

      options[:limit] ? limit = options[:limit] : limit = 1000000
      options[:start] ? get(instance_variable_get("@#{type}") + "?#{start_query(type)}=#{options[:start]}") : get(instance_variable_get("@#{type}"))

      fetch_feed(page, limit)

      @response
    end


    # add_member_to adds a member to a group in the domain.
    # It takes a group_id and a GoogleApps::Atom::GroupMember
    # document as arguments.
    #
    # add_member_to 'test', document
    #
    # add_member_to returns the response received from Google.
    def add_member_to(group_id, document)
      add(@group + "/#{group_id}/member", document)
    end


    # delete_member_from removes a member from a group in the
    # domain.  It takes a group_id and member_id as arguments.
    #
    # delete_member_from 'test_group', 'member@cnm.edu'
    #
    # delete_member_from returns the respnse received from Google.
    def delete_member_from(group_id, member_id)
      delete(@group + "/#{group_id}/member", member_id)
    end


    # get_nicknames_for retrieves all the nicknames associated
    # with the requested user.  It takes the username as a string.
    #
    # get_nickname_for 'lholcomb2'
    #
    # get_nickname_for returns the HTTP response from Google
    def get_nicknames_for(login)
      get_nickname "?username=#{login}"
    end


    # add is a generic target for method_missing.  It is
    # intended to handle the general case of adding
    # to the GoogleApps Domain.  It takes an API endpoint
    # and a GoogleApps::Atom document as arguments.
    #
    # add 'endpoint', document
    #
    # add returns the HTTP response received from Google.
    def add(endpoint, document)
      uri = URI(endpoint)
      @request = Net::HTTP::Post.new(uri.path)
      @request.body = document.to_s
      set_headers :user

      @response = request uri
    end

    # update is a generic target for method_missing.  It is
    # intended to handle the general case of updating an
    # item that already exists in your GoogleApps Domain.
    # It takes an API endpoint and a GoogleApps::Atom document
    # as arguments.
    #
    # update 'endpoint', document
    #
    # update returns the HTTP response received from Google
    def update(endpoint, target, document)
    	# TODO: Username needs to come from somewhere for uri
      uri = URI(endpoint + "/#{target}")
      @request = Net::HTTP::Put.new(uri.path)
      @request.body = document.to_s
      set_headers :user

      @response = request uri
    end

    # delete is a generic target for method_missing.  It is
    # intended to handle the general case of deleting an
    # item from your GoogleApps Domain.  delete takes an
    # API endpoint and an item identifier as argumets.
    #
    # delete 'endpoint', 'id'
    #
    # delete returns the HTTP response received from Google.
    def delete(endpoint, id)
      uri = URI(endpoint + "/#{id}")
      @request = Net::HTTP::Delete.new(uri.path)
      set_headers :user

      @response = request uri
    end

    # migration performs mail migration from a local
    # mail environment to GoogleApps.  migrate takes a
    # username a GoogleApps::Atom::Properties dcoument
    # and the message as plain text (String) as arguments.
    #
    # migrate 'user', properties, message
    #
    # migrate returns the HTTP response received from Google.
    def migrate(username, properties, message)
      uri = URI(@migration + "/#{username}/mail")
      @request = Net::HTTP::Post.new(uri.path)
      @request.body = multi_part(properties.to_s, message)
      set_headers :migrate

      @response = request uri
    end


    # TODO: This should perform the instance_variable_get and pass the value to the appropriate method.
    def method_missing(name, *args)
      super unless name.match /([a-z]*)_([a-z]*)/

      case $1
      when "new", "add"
        self.send(:add, instance_variable_get("@#{$2}"), *args)
      when "delete"
        self.send(:delete, instance_variable_get("@#{$2}"), *args)
      when "update"
        self.send(:update, instance_variable_get("@#{$2}"), *args)
      when "get"
        self.send(:get, instance_variable_get("@#{$2}"), *args)
      else
        super
      end
    end


    private


    # auth_body generates the body for the authentication
    # request made by authenticate.
    #
    # auth_body 'username@domain', 'password'
    #
    # auth_body returns a string in the form of HTTP
    # query parameters.
    def auth_body(account, pass)
      "&Email=#{CGI::escape(account)}&Passwd=#{CGI::escape(pass)}&accountType=HOSTED&service=apps"
    end


    # build_id checks the id string.  If it is formatted
    # as a query string it is returned as is.  If not
    # a / is prepended to the id string.
    def build_id(id)
      id =~ /^\?/ ? id : "/#{id}"
    end


    # Grab the auth token from the response body
    def set_auth_token
      @response.body.split("\n").grep(/auth=(.*)/i)

      @token = $1
    end


    # get_next_page retrieves the next page in the response.
    def get_next_page
      get @feeds.last.next_page
      add_feed
    end


    # fetch_feed retrieves the remaining pages in the request.
    # It takes a page and a limit as arguments.
    def fetch_feed(page, limit)
      add_feed
      page += 1

      while (@feeds.last.next_page) and (page * PAGE_SIZE[:user] < limit)
        get_next_page
        page += 1
      end
    end


    # start_query builds the value for the starting point
    # query string used for retrieving batches of objects
    # from Google.
    def start_query(type)
      case type
      when 'user'
        "startUsername"
      when 'group'
        "startGroup"
      end
    end


    def normalize_type(type)
      type.to_s.gsub!(/\w*s$/) { |match| match[0..-2] }
    end


    # add_feed adds a feed to the @feeds array.
    def add_feed
      @feeds << GoogleApps::Atom.feed(@response.body)
    end


    def request(uri)
      # TODO: Clashes with @request reader
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(@request)
      end
    end

    def set_headers(request_type)
      case request_type
      when :auth
        @request['content-type'] = "application/x-www-form-urlencoded"
      when :migrate
        @request['content-type'] = "multipart/related; boundary=\"#{BOUNDARY}\""
        @request['authorization'] = "GoogleLogin auth=#{@token}"
      else
        @request['content-type'] = "application/atom+xml"
        @request['authorization'] = "GoogleLogin auth=#{@token}"
      end
    end

    def multi_part(properties, message)
      post_body = []
      post_body << "--#{BOUNDARY}\n"
      post_body << "Content-Type: application/atom+xml\n\n"
      post_body << properties.to_s
      post_body << "\n--#{BOUNDARY}\n"
      post_body << "Content-Type: message/rfc822\n\n"
      post_body << message.to_s
      post_body << "\n--#{BOUNDARY}--}"

      post_body.join
    end
  end
end