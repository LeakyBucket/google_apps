require 'cgi'
require 'openssl'
require 'rexml/document'

module GoogleApps
  class Transport
    attr_reader :request, :response, :domain, :feeds
    attr_accessor :auth, :user, :group, :nickname, :export, :group, :requester, :migration

    SUCCESS_CODES = [200, 201, 202]
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
      @requester = AppsRequest || targets[:requester]
      @doc_handler = DocumentHandler.new format: (targets[:format] || :atom)
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
      add(@auth, auth_body(account, pass), :auth)

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
    # request_export returns the request ID on success or
    # the HTTP response object on failure.
    def request_export(username, document)
      add(@export + "/#{username}", document)

      success_response? ? get_values('apps:property', ['name', 'requestId'], 'value')[0].to_i : @response
    end


    # export_status checks the status of a mailbox export
    # request.  It takes the username and the request_id
    # as arguments
    #
    # export_status 'username', 847576
    #
    # export_status will return the body of the HTTP response
    # from Google
    def export_status(username, req_id)
      get(@export + "/#{username}", req_id)

      @response.body
    end


    # export_ready? checks the export_status response for the
    # presence of an apps:property element with a fileUrl name
    # attribute.
    #
    # export_ready? 'lholcomb2', 82834
    #
    # export_ready? returns true if there is a fileUrl present
    # in the response and false if there is no fileUrl present
    # in the response.
    def export_ready?(username, req_id)
      export_status(username, req_id)

      !(export_file_urls.empty?) unless !success_response?
    end


    # fetch_export downloads the mailbox export from Google.
    # It takes a username, request id and a filename as
    # arguments.  If the export consists of more than one file
    # the file name will have numbers appended to indicate the
    # piece of the export.
    #
    # fetch_export 'lholcomb2', 838382, 'lholcomb2'
    #
    # fetch_export reutrns nil in the event that the export is
    # not yet ready.
    def fetch_export(username, req_id, filename)
      if export_ready?(username, req_id)
        download_export(filename).each_with_index { |url, index| url.gsub!(/.*/, "#{filename}#{index}")}
      else
        nil
      end
    end


    # download makes a get request of the provided url
    # and writes the body to the provided filename.
    #
    # download 'url', 'save_file'
    def download(url, filename)
      @request = @requester.new :get, URI(url), headers(:other)

      File.open(filename, "w") do |file|
        file.puts @request.send_request.body
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
      id ? uri = URI(endpoint + build_id(id)) : uri = URI(endpoint)
      @request = @requester.new :get, uri, headers(:other)

      @response = @request.send_request
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
    def add(endpoint, document, header_type = nil)
      header_type = :others unless header_type
      uri = URI(endpoint)
      @request = @requester.new :post, uri, headers(header_type)
      @request.add_body document.to_s

      @response = @request.send_request
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
      uri = URI(endpoint + "/#{target}")
      @request = @requester.new :put, uri, headers(:other)
      @request.add_body document.to_s

      @response = @request.send_request
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
      @request = @requester.new :delete, uri, headers(:other)

      @response = @request.send_request
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
      @request = @requester.new(:post, URI(@migration + "/#{username}/mail"), headers(:migration))
      @request.add_body multi_part(properties.to_s, message)

      @request.send_request
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


    # get_values returns an array of all the value attributes
    # on elements matching the given key_attrib pair on the
    # specified element type.
    def get_values(element, key_attrib, value = 'value')
      Atom::XML::Document.string(@response.body).find('//' + element).inject([]) do |values, element|
        values << element.attributes[value] if element.attributes[key_attrib[0]].match key_attrib[1]
        values
      end
    end


    # export_file_urls searches @response for any apps:property elements with a
    # fileUrl name attribute and returns an array of the values.
    def export_file_urls
      Atom::XML::Document.string(@response.body).find('//apps:property').inject([]) do |urls, prop|
        urls << prop.attributes['value'] if prop.attributes['name'].match 'fileUrl'
        urls
      end
    end


    def download_export(filename)
      export_file_urls.each_with_index do |url, index|
        download(url, filename + "#{index}")
      end
    end


    # process_response takes the HTTPResponse and either returns a
    # document of the specified type or in the event of an error it
    # returns the HTTPResponse.
    def process_response(doc_type)
      success_response? ? @handler.doc_of_type(doc_type, @response.body) : @response
    end


    # error_response? checks to see if Google Responded with a success
    # code.
    def success_response?
      SUCCESS_CODES.include?(@response.code.to_i)
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


    def headers(category)
      case category
      when :auth
        [['content-type', 'application/x-www-form-urlencoded']]
      when :migration
        [['content-type', "multipart/related; boundary=\"#{BOUNDARY}\""], ['authorization', "GoogleLogin auth=#{@token}"]]
      else
        [['content-type', 'application/atom+xml'], ['authorization', "GoogleLogin auth=#{@token}"]]
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