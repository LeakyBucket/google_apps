require 'spec_helper'

describe "GoogleApps::Transport" do
  let (:transporter) { GoogleApps::Transport.new "cnm.edu" }
  let (:user_doc) { GoogleApps::Atom::User.new }
  let (:credentials) { get_credentials }
  let (:user_name) { generate_username }

  describe '#new' do
    it "assigns endpoints and sets @token to nil" do
      transporter.instance_eval { @token }.should be(nil)
      transporter.instance_eval { @auth }.should == "https://www.google.com/accounts/ClientLogin"
      transporter.instance_eval { @user }.should == "https://apps-apis.google.com/a/feeds/cnm.edu/user/2.0"
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
      transporter.add_member_to 'Test', 'Bob'
      base_path = get_path("group")

      transporter.instance_eval { @request }.should be_a Net::HTTP::Post
      transporter.instance_eval { @request.path }.should == "/#{base_path}/Test/Bob"
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

  describe '#add_user' do
    it "sends a POST request to the User endpoint" do
      transporter.add_user user_doc

      transporter.instance_eval { @request }.should be_a Net::HTTP::Post
      transporter.instance_eval { @request.body }.should include user_doc.to_s
    end
  end
end