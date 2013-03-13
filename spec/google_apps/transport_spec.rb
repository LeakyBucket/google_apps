require 'spec_helper'

describe GoogleApps::Transport do
  let (:mock_request) { mock(GoogleApps::AppsRequest) }
  let (:mock_response) { mock(Net::HTTPResponse) }
  let (:user_doc) { GoogleApps::Atom::User.new File.read('spec/fixture_xml/user.xml') }
  let (:credentials) { get_credentials }
  let (:user_name) { generate_username }
  let (:document) { mock(GoogleApps::Atom::User).stub!(:to_s).and_return("stub xml") }

  before(:each) do
    @headers = {
      auth: [['content-type', 'application/x-www-form-urlencoded']],
      migration: [['content-type', "multipart/related; boundary=\"#{GoogleApps::Transport::BOUNDARY}\""], ['Authorization', "OAuth #{transporter.instance_eval { @token } }"]],
      other: [['content-type', 'application/atom+xml'], ['Authorization', "OAuth #{transporter.instance_eval { @token } }"]]
    }

    GoogleApps::AppsRequest.stub(:new).and_return(mock_request)

    mock_request.stub(:send_request).and_return(mock_response)
    mock_request.stub(:add_body)
  end

  let(:transporter) do
    GoogleApps::Transport.new(
        domain: 'cnm.edu',
        token: 'some-token',
        refresh_token: 'refresh_token',
        token_changed_callback: 'callback-proc'
    )
  end

  describe '#new' do
    it "assigns endpoints" do
      transporter.user.should == "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0"
      transporter.group.should == "https://apps-apis.google.com/a/feeds/group/2.0/cnm.edu"
      transporter.nickname.should == "https://apps-apis.google.com/a/feeds/cnm.edu/nickname/2.0"
      transporter.pubkey.should == "https://apps-apis.google.com/a/feeds/compliance/audit/publickey/cnm.edu"
      transporter.export.should == "https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu"
      transporter.migration.should == "https://apps-apis.google.com/a/feeds/migration/2.0/cnm.edu"
    end
  end

  describe "#add_member_to" do
    it "creates an HTTP POST request to add a member to a group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.group + '/Test/member'), @headers[:other])
      transporter.should_receive(:success_response?).and_return(true)

      mock_request.should_receive :add_body
      mock_response.should_receive(:body).and_return("document")
      transporter.stub(:create_doc)

      transporter.add_member_to 'Test', 'Bob'
      get_path("group")
    end
  end

  describe "#add_owner_to" do
    before(:each) do
      @owner_doc = double(GoogleApps::Atom::GroupOwner)
    end

    it "adds the specified address as an owner of the specified group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.group + '/test_group@cnm.edu/owner'), @headers[:other])
      transporter.add_owner_to 'test_group@cnm.edu', @owner_doc
    end
  end

  describe "#delete_owner_from" do
    it "Deletes the owner from the group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:delete, URI(transporter.group + '/test_group@cnm.edu/owner/lholcomb2@cnm.edu'), @headers[:other])

      transporter.delete_owner_from 'test_group@cnm.edu', 'lholcomb2@cnm.edu'
    end
  end

  describe "#get_nicknames_for" do
    it "Gets a feed of the nicknames for the requested user" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.nickname + '?username=lholcomb2'), @headers[:other])
      transporter.should_receive(:success_response?).and_return(true)
      mock_response.should_receive(:body).and_return(fake_nickname)

      transporter.get_nicknames_for 'lholcomb2'
    end
  end

  describe "#delete_member_from" do
    it "crafts an HTTP DELETE request for a group member" do
      GoogleApps::AppsRequest.should_receive(:new).with(:delete, URI(transporter.group + '/next_group/member/lholcomb2@cnm.edu'), @headers[:other])
      transporter.delete_member_from 'next_group', 'lholcomb2@cnm.edu'
    end
  end

  describe "#request_export" do
    before(:each) do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.export + '/lholcomb2'), @headers[:other])
    end

    it "crafts a HTTP POST request for a mailbox export" do
      mock_response.should_receive(:body).and_return(pending_export)
      transporter.should_receive(:success_response?).and_return(true)
      transporter.request_export('lholcomb2', document).should == 75133001
    end

    it "Crafts a HTTP POST request and raises an error if Google returns an error" do
      transporter.should_receive(:success_response?).and_return(false)
      expect { transporter.request_export('lholcomb2', document) }.to raise_error
    end
  end

  describe "#export_status" do
    before(:each) do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + '/lholcomb2/83838'), @headers[:other])
      mock_response.stub(:body).and_return(pending_export)
      transporter.stub(:success_response?).and_return(true)
    end

    it "crafts a HTTP GET request for a mailbox export status" do
      transporter.export_status 'lholcomb2', 83838
    end

    it "Returns the response body from Google" do
      transporter.export_status('lholcomb2', 83838).should be_a LibXML::XML::Document
    end
  end

  describe "#build_id" do
    it "Returns a query string unchanged" do
      transporter.send(:build_id, '?bob').should == '?bob'
    end

    it "Prepends a slash to non-query strings" do
      transporter.send(:build_id, 'tom').should == '/tom'
    end
  end

  describe '#add_user' do
    it "sends a POST request to the User endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.user), @headers[:other])
      mock_request.should_receive(:add_body).with user_doc.to_s
      transporter.should_receive(:success_response?).and_return(true)
      mock_response.should_receive(:body).and_return(File.read('spec/fixture_xml/user.xml'))

      transporter.add_user user_doc
    end
  end

  describe "#get_users" do
    before(:each) do
      mock_response.stub(:body).and_return(File.read('spec/fixture_xml/users_feed.xml'))
      transporter.stub(:success_response?).and_return(true)
    end

    it "Builds a GET request for the user endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.user + '?startUsername=znelson1'), @headers[:other])
      transporter.get_users start: 'znelson1', limit: 2
    end
  end

  describe "#download" do
    before(:all) do
      @url = 'http://www.google.com'
      @filename = 'spec/download_test'
    end

    before(:each) do
      mock_response.stub(:body).and_return("Test body")
    end

    after(:all) do
      File.delete('spec/download_test')
    end

    it "Makes a GET request for the specified url" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(@url), @headers[:other])
      mock_response.should_receive(:body)

      transporter.download @url, @filename
    end

    it "Saves the response body to the specified filename" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(@url), @headers[:other])
      mock_response.should_receive(:body)
      transporter.download @url, @filename

      File.read('spec/download_test').should == "Test body\n"
    end
  end

  describe "#migrate" do
    it "Make a POST request to the migration endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.migration + "/#{user_name}/mail"), @headers[:migration])
      mock_request.should_receive(:add_body).with(transporter.send(:multi_part, "bob", "cat"))

      transporter.migrate(user_name, "bob", "cat")
    end
  end

  describe "#export_ready?" do
    before(:all) do
      @id = 828456
    end

    it "Returns true if there is a fileUrl property in an export status doc" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + "/#{user_name}/#{@id}"), @headers[:other])
      mock_response.should_receive(:body).and_return(finished_export)
      transporter.should_receive(:success_response?).and_return(true)
      export_status_doc = transporter.export_status(user_name, @id)
      transporter.export_ready?(export_status_doc).should == true
    end

    it "Returns false if there is no fileUrl property in an export status doc" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + "/#{user_name}/#{@id}"), @headers[:other])
      mock_response.should_receive(:body).and_return(pending_export)
      transporter.should_receive(:success_response?).and_return(true)
      export_status_doc = transporter.export_status(user_name, @id)

      transporter.export_ready?(export_status_doc).should == false
    end
  end

  describe "#process_response" do
    before(:each) do
      @mock_handler = double(GoogleApps::DocumentHandler)
      transporter.instance_eval { @handler = @mock_handler }
    end

    it "Raises an error if Google Responds in kind" do
      transporter.should_receive(:success_response?).and_return(false)
      expect { transporter.get_user 'lholcomb2' }.to raise_error
    end
  end
end