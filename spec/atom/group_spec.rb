require 'spec_helper'

describe "GoogleApps::Atom::Group" do
  let (:group) { GoogleApps::Atom::Group.new }

  describe "#add_header" do
    it "should add the header to @document" do
      group.send(:add_header)

      group.instance_eval { @document.root }.should be_an LibXML::XML::Node
    end
  end

  describe "#new" do
    it "should initialize @document" do
      group.instance_eval { @document }.should be_a LibXML::XML::Document
    end

    it "should add the header to @document" do
      group.instance_eval { @document.root }.should be_an LibXML::XML::Node
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

  describe "#to_s" do
    it "should present @document as a string" do
      group.to_s.should be_a String
    end
  end
end