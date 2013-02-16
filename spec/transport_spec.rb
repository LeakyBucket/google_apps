require 'spec_helper'

describe "GoogleApps::Transport" do
  let (:mock_request) { mock(GoogleApps::AppsRequest) }
  let (:mock_response) { mock(Net::HTTPResponse) }
  let (:transporter) { GoogleApps::Transport.new "cnm.edu" }
  let (:user_doc) { GoogleApps::Atom::User.new File.read('spec/xml/user.xml') }
  let (:credentials) { get_credentials }
  let (:user_name) { generate_username }
  let (:document) { mock(GoogleApps::Atom::User).stub!(:to_s).and_return("stub xml") }

  before(:all) do
    transporter.authenticate credentials['username'], credentials['password']
  end

  before(:each) do
    @headers = {
      auth: [['content-type', 'application/x-www-form-urlencoded']],
      migration: [['content-type', "multipart/related; boundary=\"#{GoogleApps::Transport::BOUNDARY}\""], ['authorization', "GoogleLogin auth=#{transporter.instance_eval { @token } }"]],
      other: [['content-type', 'application/atom+xml'], ['authorization', "GoogleLogin auth=#{transporter.instance_eval { @token } }"]]
    }

    GoogleApps::AppsRequest.stub(:new).and_return(mock_request)
    transporter.requester = GoogleApps::AppsRequest

    mock_request.stub(:send_request).and_return(mock_response)
    mock_request.stub(:add_body)
    #mock_response.stub(:body).and_return(File.read('spec/feed.xml'))
  end

  describe '#new' do
    it "assigns endpoints and sets @token to nil" do
      transport = GoogleApps::Transport.new 'cnm.edu'
      transport.instance_eval { @token }.should be(nil)
      transport.instance_eval { @auth }.should == "https://www.google.com/accounts/ClientLogin"
      transport.instance_eval { @user }.should == "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0"
    end
  end

  describe '#authenticate' do
    it "Makes an authentication request to the @auth endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.auth), @headers[:auth])
      mock_response.should_receive(:body).and_return('auth=fake_token')
      mock_response.should_receive(:code).and_return(200)

      transporter.authenticate credentials['username'], credentials['password']
    end
  end

  describe "#add_member_to" do
    it "creates an HTTP POST request to add a member to a group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.group + '/Test/member'), @headers[:other])
      mock_response.should_receive(:code).and_return(200)

      mock_request.should_receive :add_body

      transporter.add_member_to 'Test', 'Bob'
      base_path = get_path("group")
    end
  end

  describe "#add_owner_to" do
    before(:each) do
      @owner_doc = double(GoogleApps::Atom::GroupOwner)
    end

    it "adds the specified address as an owner of the specified group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.group + '/test_group@cnm.edu/owner'), @headers[:other])
      mock_response.should_receive(:code).and_return(200)

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
      mock_response.should_receive(:code).and_return(200)
      mock_response.should_receive(:body).and_return(fake_nickname)

      transporter.get_nicknames_for 'lholcomb2'

      #transporter.response.body.should include '2006#nickname'
    end
  end

  describe "#delete_member_from" do
    it "crafts an HTTP DELETE request for a group member" do
      GoogleApps::AppsRequest.should_receive(:new).with(:delete, URI(transporter.group + '/next_group/member/lholcomb2@cnm.edu'), @headers[:other])
      transporter.delete_member_from 'next_group', 'lholcomb2@cnm.edu'
    end
  end

  describe '#auth_body' do
    it "builds the POST body for the authenticate request" do
      transporter.send(:auth_body, "not real user", "not real password").should be_a(String)
    end
  end

  describe "#set_auth_token" do
    before(:each) do
      mock_response.stub(:body).and_return('auth=fake_token')
    end

    it "should set @token to the value found in the response body" do
      transporter.send(:set_auth_token)

      transporter.instance_eval { @token }.should == 'fake_token'
    end
  end

  describe "#request_export" do
    before(:each) do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.export + '/lholcomb2'), @headers[:other])
    end

    it "crafts a HTTP POST request for a mailbox export" do
      mock_response.should_receive(:body).and_return(pending_export)
      mock_response.should_receive(:code).and_return(200)

      transporter.request_export('lholcomb2', document).should == 75133001
    end

    it "Crafts a HTTP POST request and raises an error if Google returns an error" do
      mock_response.should_receive(:code).twice.and_return(404)
      mock_response.should_receive(:message).and_return('Ooops')

      lambda { transporter.request_export('lholcomb2', document) }.should raise_error
    end
  end

  describe "#export_status" do
    before(:each) do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + '/lholcomb2/83838'), @headers[:other])
      mock_response.should_receive(:body).and_return(pending_export)
      mock_response.should_receive(:code).and_return(200)
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
      mock_response.should_receive(:code).and_return(200)
      mock_response.should_receive(:body).and_return(File.read('spec/xml/user.xml'))

      transporter.add_user user_doc
    end
  end

  describe "#get_users" do
    before(:each) do
      mock_response.stub(:body).and_return(File.read('spec/feed.xml'))
      mock_response.should_receive(:code).and_return(200)
    end

    it "Builds a GET request for the user endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.user + '?startUsername=znelson1'), @headers[:other])
      transporter.get_users start: 'znelson1', limit: 2
    end

    it "Makes another request if the response has a <link rel=\"next\" node"
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

    it "Returns true if there is a fileUrl property in @response.body" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + "/#{user_name}/#{@id}"), @headers[:other])
      mock_response.should_receive(:body).twice.and_return(finished_export)
      mock_response.should_receive(:code).and_return(200)

      transporter.export_ready?(user_name, @id).should == true
    end

    it "Returns false if there is no fileUrl property in @response.body" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + "/#{user_name}/#{@id}"), @headers[:other])
      mock_response.should_receive(:body).twice.and_return(pending_export)
      mock_response.should_receive(:code).and_return(200)

      transporter.export_ready?(user_name, @id).should == false
    end
  end

  describe "#process_response" do
    before(:each) do
      @mock_handler = double(GoogleApps::DocumentHandler)
      transporter.instance_eval { @handler = @mock_handler }
    end

    xit "Return a Document Object if Google doesn't return an error" do
      mock_response.should_receive(:code).and_return(200)
      mock_response.should_receive(:body).and_return(File.read('spec/xml/user.xml'))
      @mock_handler.should_receive(:doc_of_type).and_return(user_doc)

      transporter.update_user 'lholcomb2', user_doc

      transporter.send(:process_response, :user).class.should == GoogleApps::Atom::User
    end

    it "Raises an error if Google Responds in kind" do
      mock_response.should_receive(:code).twice.and_return(400)
      mock_response.should_receive(:message).and_return("Ooops")

      lambda { transporter.get_user 'lholcomb2' }.should raise_error
    end
  end
end