require 'rexml/document'

module GoogleApps
  module ProvisioningApi
    module Users
      attr_accessor :login, :first_name, :last_name
      def all_users
        begin
          response = make_request(:get, user_url, headers: {'content-type' => 'application/atom+xml'})
          atom_feed = REXML::Document.new(response.body)
          atom_feed.elements.collect('//entry') { |e| from_entry(e) }
        rescue RestClient::ResourceNotFound
          nil
        end
      end

      def find_user(login)
        begin
          response = make_request(:get, user_url + "/#{login}")
          atom_feed = REXML::Document.new(response.body)
          from_entry(atom_feed.elements['//entry'])
        rescue RestClient::ResourceNotFound
          nil
        end
      end

      private
      def user_url
        "https://apps-apis.google.com/a/feeds/#{domain}/user/2.0"
      end

      def from_entry(atom_entry)
        GoogleApps::User.new(
            :login => atom_entry.elements["apps:login"].attribute("userName").value,
            :given_name => atom_entry.elements["apps:name"].attribute("givenName").value,
            :family_name => atom_entry.elements["apps:name"].attribute("familyName").value,
            :storage_quota => atom_entry.elements["apps:quota"].attribute("limit").value.to_i,
        )
      end
    end
  end
end