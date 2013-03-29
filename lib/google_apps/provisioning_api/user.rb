class GoogleApps
  module ProvisioningApi
    class User
      attr_accessor :login, :given_name, :family_name, :storage_quota, :hashed_password, :suspended
      alias_method :last_name, :family_name
      alias_method :first_name, :given_name
      alias_method :suspended?, :suspended

      def initialize(attrs = {})
        self.attributes = attrs
      end

      def self.all
        begin
          response = GoogleApps.client.make_request(:get, user_url, headers: {'content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          atom_feed.elements.collect('//entry') { |e| from_entry(e) }
        rescue RestClient::ResourceNotFound
          nil
        end
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

      private
      def self.user_url
        "https://apps-apis.google.com/a/feeds/#{GoogleApps.client.domain}/user/2.0"
      end

      def self.from_entry(atom_entry)
        new(
            :login => atom_entry.elements["apps:login"].attribute("userName").value,
            :given_name => atom_entry.elements["apps:name"].attribute("givenName").value,
            :family_name => atom_entry.elements["apps:name"].attribute("familyName").value,
            :storage_quota => atom_entry.elements["apps:quota"].attribute("limit").value.to_i,
        )
      end

      def attributes=(attrs)
        attrs && attrs.each_pair { |name, value| self.send("#{name}=", value) }
      end
    end
  end
end