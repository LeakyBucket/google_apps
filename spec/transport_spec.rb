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
      transporter.authenticate(credentials['username'][0], credentials['password'][0])

      transporter.response.should be_a Net::HTTPOK
      transporter.instance_eval { @token }.should be_a String
    end
  end

  describe '#auth_body' do
    it "builds the POST body for the authenticate request" do
      transporter.send(:auth_body, "lholcomb2@cnm.edu", "CNMtr4cksth3m").should be_a(String)
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