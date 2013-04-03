class GoogleApps
  module ProvisioningApi
    class User
      attr_accessor :login, :first_name, :last_name, :storage_quota, :suspended, :admin
      alias_method :suspended?, :suspended
      alias_method :admin?, :admin

      def initialize(attrs = {})
        attrs.each_pair { |name, value| self.send("#{name}=", value) }
      end

      def self.all
        response = GoogleApps.client.make_request(:get, user_url, headers: {'content-type' => 'application/atom+xml'})
        atom_feed = REXML::Document.new(response.body)
        atom_feed.elements.collect('//entry') { |e| from_entry(e) }
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
        document = <<-XML
<atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
            xmlns:apps='http://schemas.google.com/apps/2006'>
  <apps:property name="password" value="#{attrs[:password]}"/>
  <apps:property name="hashFunction" value="SHA-1"/>
  <apps:property name="userEmail" value="#{attrs[:email]}"/>
  <apps:property name="firstName" value="#{attrs[:first_name]}"/>
  <apps:property name="lastName" value="#{attrs[:last_name]}"/>
  <apps:property name="isAdmin" value="#{attrs[:admin]}"/>
  <apps:property name="isSuspended" value="#{attrs[:suspended]}"/>
</atom:entry>
        XML
        begin
          response = GoogleApps.client.make_request(:post, user_url, body: document, headers: {'Content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          from_entry(atom_feed.elements['//entry'])
        rescue
          nil
        end
      end

      def update(attrs = {})

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