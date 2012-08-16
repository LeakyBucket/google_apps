require 'spec_helper'

describe "GoogleApps::Atom::Group" do
  let (:group) { GoogleApps::Atom::Group.new }

  describe "#new" do
    it "should initialize @document" do
      group.instance_eval { @doc }.should be_a LibXML::XML::Document
    end

    it "should add the header to @document" do
      group.instance_eval { @doc.root }.should be_an LibXML::XML::Node
    end
  end

  describe "#new_group" do
    it "should add the properties for the specified group to @document" do
      group.new_group id: 'ruby', name: 'Ruby', description: 'Ruby Library Test Group', perms: 'Domain'

      document = group.to_s

      document.should include 'ruby'
      document.should include 'Ruby'
      document.should include 'Library'
      document.should include 'Domain'
    end
  end

  describe "#set_values" do
    it "should set the specified values in the XML document" do
      group.set_values id: 'sample', name: 'Test', description: 'Test Group', perms: 'Domain'
      document = group.to_s

      document.should include 'sample'
      document.should include 'Test'
      document.should include 'Test Group'
      document.should include 'Domain'
    end

    it "should only set the id if nothing else is specified" do
      group.set_values id: 'sample'
      document = group.to_s

      document.should include 'sample'
      document.should include 'groupId'
      document.should_not include 'groupName'
      document.should_not include 'description'
      document.should_not include 'emailPermissions'
    end

    it "should only set the name if nothing else is specified" do
      group.set_values name: 'Name'
      document = group.to_s

      document.should include 'Name'
      document.should include 'groupName'
      document.should_not include 'groupId'
      document.should_not include 'description'
      document.should_not include 'emailPermissions'
    end

    it "should only set the description if nothing else is specified" do
      group.set_values description: 'Test Group'
      document = group.to_s

      document.should include 'description'
      document.should include 'Test Group'
      document.should_not include 'groupId'
      document.should_not include 'groupName'
      document.should_not include 'emailPermissions'
    end
  end

  describe "#id=" do
    before(:all) do
      group.id = 'ID'
    end

    it "Sets the @id value if not already set" do
      group.id.should == 'ID'
      group.to_s.should include 'ID'
    end

    it "Changes the @id value if it is already set" do
      group.id = 'New ID'

      group.id.should == 'New ID'
      group.to_s.should include 'New ID'
      group.to_s.should_not include 'value="ID"'
    end
  end

  describe "#name=" do
    before(:all) do
      group.name = 'Group'
    end

    it "Sets @name if not already set" do
      group.name.should == 'Group'
      group.to_s.should include 'Group'
    end

    it "Changes the value of @name if already set" do
      group.name = 'Fancy Group'

      group.name.should == 'Fancy Group'
      group.to_s.should include 'Fancy Group'
      group.to_s.should_not include 'value="Group"'
    end
  end

  describe "#description=" do
    before(:all) do
      group.description = 'Description'
    end

    it "Sets @description if not already set" do
      group.description.should == 'Description'
      group.to_s.should include 'Description'
    end

    it "Changes @description if already set" do
      group.description = 'Elaborate Description'

      group.description.should == 'Elaborate Description'
      group.to_s.should include 'Elaborate Description'
      group.to_s.should_not include 'value="Description"'
    end
  end

  describe "#permissions=" do
    before(:all) do
      group.permissions = 'Allow'
    end

    it "Sets @permissions if not already set" do
      group.permissions.should == 'Allow'
      group.to_s.should include 'Allow'
    end

    it "Changes @permissions if already set" do
      group.permissions = 'Deny'

      group.permissions.should == 'Deny'
      group.to_s.should include 'Deny'
      group.to_s.should_not include 'Allow'
    end
  end

  describe "#to_s" do
    it "should present @document as a string" do
      group.to_s.should be_a String
    end
  end
end