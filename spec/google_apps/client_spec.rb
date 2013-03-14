require 'spec_helper'


describe GoogleApps::Client do
  ClientClass = Class.new do
    include HTTParty
    include GoogleApps::Client
    def initialize(domain)
      set_initial_values(domain)
    end

    def get(endpoint, id = nil)
      id ? uri = URI(endpoint + build_id(id)) : uri = URI(endpoint)
      self.class.get(uri.to_s)
    end

    def post(url, document, migration_headers = nil)
      self.class.post(url, body: document.to_s, headers: migration_headers)
    end

    def delete(endpoint, id = nil)
      uri = URI(endpoint + "/#{id}")
      self.class.delete(uri.to_s)
    end
  end

  let (:mock_response) { mock(Net::HTTPResponse, :body => "Some body") }
  let (:user_doc) { GoogleApps::Atom::User.new File.read('spec/fixture_xml/user.xml') }
  let (:user_name) { 'some7user' }
  let (:document) { mock(GoogleApps::Atom::User).stub!(:to_s).and_return("stub xml") }
  let(:client) { ClientClass.new('cnm.edu') }

  before(:each) do
    @headers = {
        migration:
            {'content-type' => "multipart/related; boundary=\"#{ClientClass::BOUNDARY}\"",
             'Authorization' => "OAuth #{client.instance_eval { @token } }"
            },
        other: {
            'content-type' => 'application/atom+xml',
            'Authorization' => "OAuth #{client.instance_eval { @token } }"
        }
    }
  end


  describe '#new' do
    it "assigns endpoints" do
      client.user.should == "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0"
      client.group.should == "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu"
      client.nickname.should == "https://apps-apis.google.com/a/feeds/cnm.edu/nickname/2.0"
      client.pubkey.should == "https://apps-apis.google.com/a/feeds/compliance/audit/publickey/cnm.edu"
      client.export.should == "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu"
      client.migration.should == "https://apps-apis.google.com/a/feeds/migration/2.0/cnm.edu"
    end
  end

  describe "#add_member_to" do
    it "creates an HTTP POST request to add a member to a group" do
      client.stub(:create_doc)
      stub_request(:post, "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu/Test/member").
          with(:body => "Bob").to_return(:status => 200)

      client.add_member_to 'Test', 'Bob'
    end
  end

  describe "#add_owner_to" do
    it "adds the specified address as an owner of the specified group" do
      stub_request(:post, "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu/test_group@cnm.edu/owner").
          with(:body => "group owner doc").to_return(:status => 200)

      client.add_owner_to 'test_group@cnm.edu', "group owner doc"
    end
  end

  describe "#delete_owner_from" do
    it "Deletes the owner from the group" do
      stub_request(:delete, "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu/test_group@cnm.edu/owner/lholcomb2@cnm.edu").
          to_return(:status => 200)
      client.delete_owner_from 'test_group@cnm.edu', 'lholcomb2@cnm.edu'
    end
  end

  describe "#get_nicknames_for" do
    it "Gets a feed of the nicknames for the requested user" do
      stub_request(:get, "https://apps-apis.google.com/a/feeds/cnm.edu/nickname/2.0?username=lholcomb2").
          to_return(:status => 200, body: fake_nickname)

      client.get_nicknames_for('lholcomb2')
    end
  end

  describe "#delete_member_from" do
    it "crafts an HTTP DELETE request for a group member" do
      stub_request(:delete, "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu/next_group/member/lholcomb2@cnm.edu").
          to_return(:status => 200)
      client.delete_member_from 'next_group', 'lholcomb2@cnm.edu'
    end
  end

  describe "#request_export" do
    before(:each) do
      stub_request(:post, "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2").
          to_return(:status => 200, :body => pending_export)
    end

    it "crafts a HTTP POST request for a mailbox export" do
      client.request_export('lholcomb2', document).should == 75133001
    end
  end

  describe "#export_status" do
    before(:each) do
      stub_request(:get, "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/83838").
          to_return(:status => 200, :body => pending_export)
    end

    it "crafts a HTTP GET request for a mailbox export status" do
      client.export_status 'lholcomb2', 83838
    end

    it "Returns the response body from Google" do
      client.export_status('lholcomb2', 83838).should be_a LibXML::XML::Document
    end
  end

  describe '#add_user' do
    it "sends a POST request to the User endpoint" do
      stub_request(:post, "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0").
          with(:body => user_doc.to_s).
          to_return(:status => 200, :body => File.read('spec/fixture_xml/user.xml'))
      client.add_user user_doc
    end
  end

  describe "#get_users" do
    it "Builds a GET request for the user endpoint" do
      stub_request(:get, "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0?startUsername=znelson1").
          to_return(:status => 200, body: File.read('spec/fixture_xml/users_feed.xml'))
      client.get_users start: 'znelson1', limit: 2
    end
  end

  describe "#download" do
    after(:all) do
      File.delete('spec/download_test')
    end

    it "Saves the response body to the specified filename" do
      stub_request(:get, "http://www.google.com/").
          to_return(:status => 200, :body => "Test body")
      client.download 'http://www.google.com', 'spec/download_test'

      File.read('spec/download_test').should == "Test body\n"
    end
  end

  describe "#migrate" do
    it "Make a POST request to the migration endpoint" do
      stub_request(:post, "https://apps-apis.google.com/a/feeds/migration/2.0/cnm.edu/some7user/mail").
          with(:body => client.send(:multi_part, "bob", "cat"),
               :headers => {'Content-Type' => 'multipart/related; boundary="=AaB03xDFHT8xgg"'}).
          to_return(:status => 200)
      client.migrate(user_name, "bob", "cat")
    end
  end

  describe "#export_ready?" do
    before(:all) do
      @id = 828456
    end

    it "Returns true if there is a fileUrl property in an export status doc" do
      stub_request(:get, "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/some7user/828456").
          to_return(:status => 200, :body => finished_export)

      export_status_doc = client.export_status(user_name, @id)
      client.export_ready?(export_status_doc).should == true
    end

    it "Returns false if there is no fileUrl property in an export status doc" do
      stub_request(:get, "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/some7user/828456").
          to_return(:status => 200, :body => pending_export)

      export_status_doc = client.export_status(user_name, @id)

      client.export_ready?(export_status_doc).should == false
    end
  end
end