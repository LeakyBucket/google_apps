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

  describe "#add_prop_node" do
    it "Adds an apps:property node to the document root" do
      node.add_prop_node 'email', 'tom', document.root

      document.to_s.should include 'value="tom"'
    end
  end

  describe "#add_attributes" do
    it "Adds the specified attributes to the given node" do
      test = LibXML::XML::Node.new 'apps:test'
      node.add_attributes(test, [['name', 'frank'], ['title', 'captain']])

      test.to_s.should include 'name="frank" title="captain"'
    end
  end

  describe "#get_content" do
    it "Returns the content of the specified node" do
      node.get_content(document, '//title').should == 'Users'
    end
  end

  describe "#add_namespaces" do
    it "Adds the specified namespaces to the given node" do
      test = node.create_node type: 'atom:entry'
      node.add_namespaces(test, atom: 'http://www.w3.org/2005/Atom')

      test.to_s.should include 'xmlns:atom="http://www.w3.org/2005/Atom"'
    end
  end
end