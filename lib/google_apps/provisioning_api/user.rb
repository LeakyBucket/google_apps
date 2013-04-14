class GoogleApps
  module ProvisioningApi
    class User
      attr_accessor :login, :first_name, :last_name, :storage_quota, :suspended, :admin, :password, :password_hash
      alias_method :suspended?, :suspended
      alias_method :admin?, :admin

      def initialize(attrs = {})
        attrs.each_pair { |name, value| self.send("#{name}=", value) }
      end

      def self.all
        response = GoogleApps.client.make_request(:get, user_url, headers: {'content-type' => 'application/atom+xml'})
        atom_feed = REXML::Document.new(response.body)
        users = atom_feed.elements.collect('//entry') { |e| from_entry(e) }
        while(atom_feed.elements["//link[@rel='next']"]) do
          response = GoogleApps.client.make_request(:get, atom_feed.elements["//link[@rel='next']"].attribute("href").value, headers: {'content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          users += atom_feed.elements.collect('//entry') { |e| from_entry(e) }
        end
        users
      end

      def self.find(login)
        begin
          response = GoogleApps.client.make_request(:get, user_url + "/#{login}")
          atom_feed = REXML::Document.new(response.body)
          from_entry(atom_feed.elements['//entry'])
        rescue RestClient::ResourceNotFound
          nil
        end
      end

      def self.create(attrs = {})
        user = User.new(attrs)
        document = Template.render('user.xml.haml', user)
        begin
          response = GoogleApps.client.make_request(:post, user_url, body: document, headers: {'Content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          from_entry(atom_feed.elements['//entry'])
        rescue RestClient::RequestFailed
          nil
        end
      end

      def self.update(login, attrs = {})
        user = User.new(attrs)
        document = Template.render('user.xml.haml', user)
        begin
          response = GoogleApps.client.make_request(:put, File.join(user_url, login), body: document, headers: {'Content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          from_entry(atom_feed.elements['//entry'])
        rescue RestClient::RequestFailed
          nil
        end
      end

      def password_hash
        return nil unless password
        Digest::SHA1.hexdigest(password)
      end

      def hash_function_name
        password ? 'SHA-1' : nil
      end

      private
      def self.user_url
        "https://apps-apis.google.com/a/feeds/#{GoogleApps.client.domain}/user/2.0"
      end

      def self.from_entry(atom_entry)
        new(
            :login => atom_entry.elements["apps:login"].attribute("userName").value,
            :admin => atom_entry.elements["apps:login"].attribute("admin").value == 'true',
            :suspended => atom_entry.elements["apps:login"].attribute("suspended").value == 'true',
            :first_name => atom_entry.elements["apps:name"].attribute("givenName").value,
            :last_name => atom_entry.elements["apps:name"].attribute("familyName").value,
            :storage_quota => atom_entry.elements["apps:quota"].attribute("limit").value.to_i,
        )
      end
    end
  end
end