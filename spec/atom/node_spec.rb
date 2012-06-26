require 'spec_helper'

describe "GoogleApps::Atom::Node" do
  let (:node_class) { class TestNode < BasicObject; include ::GoogleApps::Atom::Node; end }
  let (:node) { node_class.new }
  let (:document) { LibXML::XML::Document.file('spec/test_doc.xml') }

  describe "#create_node" do
    it "Creates a LibXML::XML::Node with the given attributes" do
      sample = node.create_node type: 'apps:nickname', attrs: [['name', 'Bob']]

      sample.to_s.should include 'apps:nickname name="Bob"'
    end

    it "Creates a Node with multiple attributes" do
      sample = node.create_node type: 'apps:nickname', attrs: [['name', 'Lou'], ['type', 'fake']]

      sample.to_s.should include 'apps:nickname name="Lou" type="fake"'
    end

    it "Creates a LibXML::XML::Node without attributes if none are given" do
      (node.create_node type: 'apps:nickname').to_s.should include 'apps:nickname'
    end
  end

  describe "#add_attributes" do
    it "Adds the specified attributes to the given node" do
      test = LibXML::XML::Node.new 'apps:test'
      node.add_attributes(test, [['name', 'frank'], ['title', 'captain']])

      test.to_s.should include 'name="frank" title="captain"'
    end
  end

  describe "#find_and_update" do
    it "Finds the specified node and updates the specified attributes" do
      node.find_and_update(document, '//apps:property', name: ['memberId', 'new'], value: ['lholcomb2@cnm.edu', 'senior'])

      document.find('//apps:property').first.attributes['name'].should == 'new'
      document.find('//apps:property').first.attributes['value'].should == 'senior'
    end
  end

  describe "#get_content" do
    it "Returns the content of the specified node" do
      node.get_content(document, '//title').should == 'Users'
    end
  end
end