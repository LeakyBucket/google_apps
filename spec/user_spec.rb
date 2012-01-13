require 'spec_helper'

describe "GoogleApps::Atom::User" do
	let (:gapp) { GoogleApps::Atom::User.new }
	let (:user) { ["test_account", "Test", "Account", "db64e604690686663821888f20373a3941ed7e95", 2048] }
  let (:document) do
'<?xml version="1.0" encoding="UTF-8"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:apps="http://schemas.google.com/apps/2006">
  <atom:category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/apps/2006#user"/>
  <apps:login userName="test_account" password="testpassword" hashFunctionName="SHA-1" suspended="false" />
  <apps:quota limit="2048" />
  <apps:name familyName="Account" givenName="Test" />
</atom:entry>'
  end

	describe '#new' do
		it "creates an empty XML document" do
			gapp.instance_eval { @document }.should be_a(LibXML::XML::Document)
		end
	end

	describe '#add' do
		it "adds a user to the Google Apps domain"
	end

  describe '#add_header' do
    it "adds the user header to the docuemnt" do
      gapp.add_header
      entry = gapp.instance_eval { @document }.root.children.first

      entry.should be_a(LibXML::XML::Node)
    end
  end

	describe '#new_user' do
		it "adds a new user record to the document" do
			gapp.new_user *user

      gapp.instance_eval { @document }.should == document
		end
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