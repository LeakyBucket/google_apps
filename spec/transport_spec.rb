require 'spec_helper'

describe "GoogleApps::Transport" do
  let (:mock_request) { mock(GoogleApps::AppsRequest) }
  let (:mock_response) { mock(Net::HTTPResponse) }
  let (:transporter) { GoogleApps::Transport.new "cnm.edu" }
  let (:user_doc) { GoogleApps::Atom::User.new }
  let (:credentials) { get_credentials }
  let (:user_name) { generate_username }
  let (:document) { mock(GoogleApps::Atom::User).stub!(:to_s).and_return("stub xml") }
  let (:headers) do
    { auth: [['content-type', 'application/x-www-form-urlencoded']],
      migration: [['content-type', "multipart/related; boundary=\"#{GoogleApps::Transport::BOUNDARY}\""], ['authorization', "GoogleLogin auth=#{transporter.instance_eval { @token } }"]],
      other: [['content-type', 'application/atom+xml'], ['authorization', "GoogleLogin auth=#{transporter.instance_eval { @token } }"]]
    }
  end

  before(:all) do
    transporter.authenticate credentials['username'], credentials['password']
  end

  before(:each) do
    GoogleApps::AppsRequest.stub(:new).and_return(mock_request)
    transporter.requester = GoogleApps::AppsRequest

    mock_response.stub(:body).and_return('body')
    mock_request.stub(:send_request).and_return(mock_response)
    mock_request.stub(:add_body)
    mock_response.stub(:body).and_return(File.read('spec/feed.xml'))
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
    it "gets the Auth token from the ClientLogin endpoint" do
      transporter.authenticate credentials['username'], credentials['password']

      transporter.response.should be_a Net::HTTPOK
      transporter.instance_eval { @token }.should be_a String
    end
  end

  describe "#add_member_to" do
    it "creates an HTTP POST request to add a member to a group" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.group + '/Test/member'), headers[:other])
      mock_request.should_receive :add_body

      transporter.add_member_to 'Test', 'Bob'
      base_path = get_path("group")
    end
  end

  describe "#get_nicknames_for" do
    it "Gets a feed of the nicknames for the requested user" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.nickname + '?username=lholcomb2'), headers[:other])

      transporter.get_nicknames_for 'lholcomb2'

      #transporter.response.body.should include '2006#nickname'
    end
  end

  describe "#delete_member_from" do
    it "crafts an HTTP DELETE request for a group member" do
      GoogleApps::AppsRequest.should_receive(:new).with(:delete, URI(transporter.group + '/next_group/member/lholcomb2@cnm.edu'), headers[:other])
      transporter.delete_member_from 'next_group', 'lholcomb2@cnm.edu'
    end
  end

  describe '#auth_body' do
    it "builds the POST body for the authenticate request" do
      transporter.send(:auth_body, "not real user", "not real password").should be_a(String)
    end
  end

  describe "#set_auth_token" do
    it "should set @token to the value found in the response body" do
      transporter.get_user user_name
      transporter.instance_eval { @response.body = "\nbob\nauth=fake_token" }
      transporter.send(:set_auth_token)

      transporter.instance_eval { @token }.should == 'fake_token'
    end
  end

  describe "#request_export" do
    it "crafts a HTTP POST request for a mailbox export" do
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.export + '/lholcomb2'), headers[:other])

      transporter.request_export 'lholcomb2', document
      base_path = get_path("export")
    end
  end

  describe "#export_status" do
    it "crafts a HTTP GET request for a mailbox export status" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.export + '/lholcomb2/83838'), headers[:other])

      transporter.export_status 'lholcomb2', 83838
      base_path = get_path("export")

      #transporter.instance_eval { @request.instance_eval { @http_request.path } }.should == "/#{base_path}/lholcomb2/83838"
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
      GoogleApps::AppsRequest.should_receive(:new).with(:post, URI(transporter.user), headers[:other])
      mock_request.should_receive(:add_body).with user_doc.to_s

      transporter.add_user user_doc

      #transporter.instance_eval { @request.body }.should include user_doc.to_s
    end
  end

  describe "#get_users" do
    it "Builds a GET request for the user endpoint" do
      GoogleApps::AppsRequest.should_receive(:new).with(:get, URI(transporter.user + '?startUsername=znelson1'), headers[:other])
      transporter.get_users start: 'znelson1', limit: 2
    end

    it "Makes another request if the response has a <link rel=\"next\" node"
  end
end