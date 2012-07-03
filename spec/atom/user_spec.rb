require 'spec_helper'

describe "GoogleApps::Atom::User" do
	let (:gapp) { GoogleApps::Atom::User.new }
	let (:user) { ["test_account", "Test", "Account", "db64e604690686663821888f20373a3941ed7e95", 2048] }
  let (:xml) { File.read('spec/xml/user.xml') }

	describe '#new' do
		it "creates an empty XML document when given no arguments" do
			gapp.document.should be_a LibXML::XML::Document
		end

    it "adds the root element to @document" do
      gapp.document.to_s.should include '<atom:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:apps="http://schemas.google.com/apps/2006">'
    end

    it "adds the category element to @document" do
      gapp.document.to_s.should include '<atom:category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/apps/2006#user"/>'
    end

    it "creates an xml document matching the given argument" do
      usr = GoogleApps::Atom.user xml

      usr.document.to_s.should include xml
    end
	end

  describe '#add_header' do
    it "adds the user header to the docuemnt" do
      gapp.send(:add_header)
      entry = gapp.document.root.children.first

      entry.should be_a(LibXML::XML::Node)
    end
  end

	describe '#new_user' do
		it "adds a new user record to the document" do
			gapp.new_user *user

      document = gapp.document.to_s

      document.should include 'test_account'
		end
	end

  # TODO: Needs to be broken out into multiple tests
  describe "#set_values" do
    it "should add nodes for the appropriate options to the document" do
      gapp.set_values username: 'bob', password: 'uncle', suspended: 'false', quota: 18567, first_name: 'uncle', last_name: 'bob'
      document = gapp.to_s

      document.should include 'userName="bob"'
      document.should include 'password='
      document.should include 'suspended="false"'
      document.should include 'limit="18567"'
      document.should include 'familyName="bob"'
      document.should include 'givenName="uncle"'
    end

    # Currently always adds suspended.  This needs to be fixed.
    it "should only add the username if nothing else is specified" do
      gapp.set_values username: 'tim'
      document = gapp.to_s

      document.should include 'userName="tim"'
      document.should_not include 'password='
      document.should_not include 'limit'
      document.should_not include 'familyName'
      document.should_not include 'givenName'
    end

    it "should only add the password if nothing else is specified" do
      gapp.set_values password: 'bananas'
      document = gapp.to_s

      document.should_not include 'userName='
      document.should include 'password='
      document.should_not include 'limit'
      document.should_not include 'familyName'
      document.should_not include 'givenName'
    end

    it "should only add the quota if nothing else is specified" do
      gapp.set_values quota: 12474
      document = gapp.to_s

      document.should_not include 'userName='
      document.should_not include 'password='
      document.should include 'limit="12474"'
      document.should_not include 'familyName'
      document.should_not include 'givenName'
    end

    it "should only add the fist name if nothing else is specified" do
      gapp.set_values first_name: 'Daisy'
      document = gapp.to_s

      document.should_not include 'userName'
      document.should_not include 'password'
      document.should_not include 'limit'
      document.should_not include 'familyName'
      document.should include 'givenName="Daisy"'
    end

    it "should only add the last name if nothing else is specified" do
      gapp.set_values last_name: 'Thomas'
      document = gapp.to_s

      document.should_not include 'userName'
      document.should_not include 'password'
      document.should_not include 'limit'
      document.should include 'familyName="Thomas"'
      document.should_not include 'givenName'
    end
  end

  describe '#login_node' do
    it "should create a google apps api node for the user_name and password" do
      login_node = gapp.login_node("test", "pancakes")

      login_node.should be_a LibXML::XML::Node
    end
  end

  describe '#quota_node' do
    it "should create a google apps api node for the quota" do
      gapp.quota_node(12868).should be_a LibXML::XML::Node
    end
  end

  describe "#find_values" do
    it "Populates instance variables with values from @document" do
      user = GoogleApps::Atom::User.new xml

      user.login.should == 'lholcomb2'
      user.suspended.should == false
      user.first_name.should == 'Lawrence'
      user.last_name.should == 'Holcomb'
    end
  end

  describe '#name_node' do
    it "should create a google apps api node for the real name" do
      gapp.name_node("Tom").should be_a LibXML::XML::Node
    end
  end
end