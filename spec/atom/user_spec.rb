require 'spec_helper'

describe "GoogleApps::Atom::User" do
	let (:gapp) { GoogleApps::Atom::User.new }
	let (:user) { ["test_account", "Test", "Account", "db64e604690686663821888f20373a3941ed7e95", 2048] }

	describe '#new' do
		it "creates an empty XML document" do
			gapp.instance_eval { @document }.should be_a(LibXML::XML::Document)
		end
	end

  describe '#add_header' do
    it "adds the user header to the docuemnt" do
      gapp.send(:add_header)
      entry = gapp.instance_eval { @document }.root.children.first

      entry.should be_a(LibXML::XML::Node)
    end
  end

	describe '#new_user' do
		it "adds a new user record to the document" do
			gapp.new_user *user

      document = gapp.instance_eval { @document.to_s }

      document.should include 'test_account'
		end
	end

  # TODO: Needs to be broken out into multiple tests
  describe "#populate_with" do
    it "should add nodes for the appropriate options to the document" do
      gapp.populate_with username: 'bob', password: 'uncle', suspended: 'false', quota: 18567, first_name: 'uncle', last_name: 'bob'
      document = gapp.to_s

      document.should include 'userName="bob"'
      document.should include 'password='
      document.should include 'suspended="false"'
      document.should include 'limit="18567"'
      document.should include 'familyName="bob"'
      document.should include 'givenName="uncle"'
    end
  end

  describe "#update_node" do
    it "should create a login node with attributes to be updated"
  end

  describe '#login_node' do
    it "creates a google apps api node for the user_name and password" do
      login_node = gapp.login_node("test", "db64e604690686663821888f20373a3941ed7e95")

      
    end
  end

  describe '#quota_node' do
    it "creates a google apps api node for the quota"
  end

  describe '#name_node' do
    it "creates a google apps api node for the real name"
  end
end