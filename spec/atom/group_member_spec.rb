require 'spec_helper'

describe "GoogleApps::Atom::GroupMember" do
  let (:member) { GoogleApps::Atom::GroupMember.new }

  describe "#new" do
    it "initializes document as an empty Atom XML Document" do
      member.instance_eval { @document }.should be_a LibXML::XML::Document
    end

    it "sets the header for @document" do
      member.instance_eval { @document.root.to_s }.should == basic_header
    end
  end

  describe "#member=" do
    it "sets the value for the member being added" do
      member.member = 'Bob'

      member.member.should == 'Bob'
    end

    it "changes the value for @member if @member is already set" do
      member.member = 'Tom'
      member.member = 'Bill'

      member.member.should == 'Bill'
      member.to_s.should include 'Bill'
      member.to_s.should_not include 'Tom'
    end
  end

  describe "#change_member" do
    it "changes the XML Node for the memberId" do
      member.member = 'Tom'
      member.member = 'Bill'

      member.instance_eval { @document.root.child.attributes['value'] }.should == 'Bill'
    end
  end

  describe "#parse_doc" do
    it "sets @document to be a parsed copy of @document" do
      member.send(:parse_doc)

      member.instance_eval { @document }.should be_a LibXML::XML::Document
    end
  end

  describe "#to_s" do
    it "returns @document as a string" do
      member.member = 'Tom'

      member.to_s.should == member.instance_eval { @document.to_s }
    end
  end
end