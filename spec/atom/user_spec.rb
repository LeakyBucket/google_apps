require 'spec_helper'

describe "GoogleApps::Atom::User" do
	let (:gapp) { GoogleApps::Atom::User.new }
	let (:user) { ["test_account", "Test", "Account", "db64e604690686663821888f20373a3941ed7e95", 2048] }
  let (:xml) { File.read('spec/xml/user.xml') }
  let (:default_password) { 'default' }

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

  describe "#set" do
    it "Adds the login attribute to the document" do
      gapp.set login: 'Zudder'

      gapp.to_s.should include 'userName="Zudder"'
    end

    it "Adds the password attributes to the document" do
      gapp.set password: 'taco salad'

      gapp.to_s.should include "password=\"#{hash_password('taco salad')}\""
      gapp.to_s.should include 'hashFunctionName="SHA'
    end

    it "Adds the quota attribute to the document" do
      gapp.set quota: 12344

      gapp.to_s.should include 'limit="12344"'
    end

    it "Adds the suspended attribute to the document" do
      gapp.set suspended: true

      gapp.to_s.should include 'suspended="true"'
    end

    it "Adds the first name to the document" do
      gapp.set first_name: 'Luke'

      gapp.to_s.should include 'givenName="Luke"'
    end

    it "Adds the last name to the document" do
      gapp.set last_name: 'Olsen'

      gapp.to_s.should include 'familyName="Olsen"'
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

  describe "#add_node" do
    it "Creates the specified node and parses the document" do
      gapp.add_node 'apps:login', [['suspended', 'false']]

      gapp.to_s.should include '<apps:login suspended="false"/>'
    end
  end

  describe "#update" do
    it "Updated an existing node with the given values" do
      gapp.add_node 'apps:login', [['userName', 'Zud']]
      gapp.instance_eval { @login = 'Zud' }
      gapp.update 'apps:login', :userName, 'Bran'

      gapp.to_s.should include 'userName="Bran"'
      gapp.to_s.should_not include 'userName="Zud"'
    end
  end

  describe "#node" do
    it "Checks the document for a node with the given name" do
      gapp.suspended = true

      gapp.node('apps:login').should_not be nil
      gapp.node('bacon').should be nil
    end
  end

  describe "#suspended=" do
    it "Sets the suspended attribute on the apps:login node" do
      gapp.suspended = true

      gapp.to_s.should include 'suspended="true"'
    end

    it "Sets @suspended to the given value" do
      gapp.suspended = true

      gapp.suspended.should == true
    end

    it "Changes the value of suspended in apps:login if already set" do
      gapp.suspended = true
      gapp.suspended = false

      gapp.to_s.should include 'suspended="false"'
      gapp.to_s.should_not include 'suspended="true"'
    end

    it "Sets @suspended to the given value if previously set" do
      gapp.suspended = true
      gapp.suspended = false

      gapp.suspended.should == false
    end
  end

  describe "#login=" do
    it "Sets the userName attribute on the apps:login node" do
      gapp.login = 'bob'

      gapp.to_s.should include 'userName="bob"'
    end

    it "Sets @login to the given value" do
      gapp.login = 'bob'

      gapp.login.should == 'bob'
    end

    it "Changes the value of userName in apps:login if already set" do
      gapp.login = 'bob'
      gapp.login = 'lou'

      gapp.to_s.should include 'userName="lou"'
      gapp.to_s.should_not include 'userName="bob"'
    end

    it "Sets @login to the given value if previously set" do
      gapp.login = 'bob'
      gapp.login = 'lou'

      gapp.login.should == 'lou'
    end
  end

  describe "#first_name=" do
    it "Sets the givenName attribute on the apps:name node" do
      gapp.first_name = 'Sam'

      gapp.to_s.should include 'givenName="Sam"'
    end

    it "Sets @first_name to the given value" do
      gapp.first_name = 'Sam'

      gapp.first_name.should == 'Sam'
    end

    it "Changes the value of givenName in apps:name if already set" do
      gapp.first_name = 'Sam'
      gapp.first_name = 'June'

      gapp.to_s.should include 'givenName="June"'
      gapp.to_s.should_not include 'givenName="Sam"'
    end

    it "Sets @first_name to the given value if previously set" do
      gapp.first_name = 'Sam'
      gapp.first_name = 'June'

      gapp.first_name.should == 'June'
    end
  end

  describe "#last_name=" do
    it "Sets the familyName attribute on the apps:name node" do
      gapp.last_name = 'Strange'

      gapp.to_s.should include 'familyName="Strange"'
    end

    it "Sets @last_name to the given value" do
      gapp.last_name = 'Strange'

      gapp.last_name.should == 'Strange'
    end

    it "Changes the value of familyName in apps:name if already set" do
      gapp.last_name = 'Strange'
      gapp.last_name = 'Parker'

      gapp.to_s.should include 'familyName="Parker"'
      gapp.to_s.should_not include 'familyName="Strange"'
    end

    it "Sets @last_name to the given value if previously set" do
      gapp.last_name = 'Strange'
      gapp.last_name = 'Parker'

      gapp.last_name.should == 'Parker'
    end
  end

  describe "#quota=" do
    it "Sets the limit attribute on the apps:quota node" do
      gapp.quota = 12354

      gapp.to_s.should include 'limit="12354"'
    end

    it "Sets @quota to the given value" do
      gapp.quota = 12354

      gapp.quota.should == 12354
    end

    it "Changes the value of limit in apps:quota if already set" do
      gapp.quota = 12354
      gapp.quota = 123456

      gapp.to_s.should include 'limit="123456"'
      gapp.to_s.should_not include 'limit="12354"'
    end

    it "Sets @quota to the given value if previously set" do
      gapp.quota = 12354
      gapp.quota = 123456

      gapp.quota.should == 123456
    end
  end

  describe "#password=" do
    before(:all) do
      @hashed = hash_password(default_password)
    end

    it "Sets the password attribute on the apps:login node" do
      gapp.password = default_password

      gapp.to_s.should include "password=\"#{@hashed}\""
    end

    it "Sets the hashFunctionName attribute on the apps:login node" do
      gapp.password = default_password

      gapp.to_s.should include "hashFunctionName=\"#{GoogleApps::Atom::HASH_FUNCTION}\""
    end

    it "Sets @password to the given value" do
      gapp.password = default_password

      gapp.password.should == @hashed
    end

    it "Updates the password attribute in apps:login if already set" do
      gapp.password = default_password
      gapp.password = 'new password'

      gapp.to_s.should include "password=\"#{hash_password('new password')}\""
      gapp.to_s.should_not include "password=\"#{@hashed}\""
    end

    it "Updates @password if previously set" do
      gapp.password = default_password
      gapp.password = 'new password'

      gapp.password.should == hash_password('new password')
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

  describe "#check_value" do
    it "Returns true if the value is 'true'" do
      gapp.send(:check_value, 'true').should == true
    end

    it "Returns flase if the value is 'false'" do
      gapp.send(:check_value, 'false').should == false
    end

    it "Returns the origional object if not == 'true' or 'false'" do
      gapp.send(:check_value, 'bob').should == 'bob'
    end
  end

  describe '#name_node' do
    it "should create a google apps api node for the real name" do
      gapp.name_node("Tom").should be_a LibXML::XML::Node
    end
  end
end