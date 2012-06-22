require 'spec_helper'

describe "GoogleApps::Atom::Node" do
  let (:node_class) { class TestNode < BasicObject; include ::GoogleApps::Atom::Node; end }
  let (:node) { node_class.new }

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
end