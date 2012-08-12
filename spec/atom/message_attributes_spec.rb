require 'spec_helper'

describe "GoogleApps::Atom::MessageAttributes" do
  let (:attributes) { GoogleApps::Atom::MessageAttributes.new }

  describe "#new" do
    it "should initialize @document to a LibXML::XML::Document" do
      attributes.instance_eval { @document }.should be_a LibXML::XML::Document
    end

    it "should set the @document header" do
      attributes.to_s.should include 'term'
      attributes.to_s.should include 'scheme'
      attributes.to_s.should include 'type'
    end
  end

  describe "#to_s" do
    it "should return @document as a String" do
      attributes.to_s.should be_a String
    end
  end

  describe "#add_property" do
    it "should add a property attribute to @document" do
      attributes.add_property 'IS_INBOX'

      attributes.to_s.should include 'mailItemProperty'
      attributes.to_s.should include 'IS_INBOX'
    end
  end

  describe "#add_label" do
    it "should add a label attribute to @document" do
      attributes.add_label 'Migration'

      attributes.to_s.should include 'label'
      attributes.to_s.should include 'Migration'
    end
  end

  describe "#find_labels" do
    before(:all) do
      @fetched = GoogleApps::Atom::MessageAttributes.new File.read('spec/xml/mes_attr.xml')
    end

    it "Populates @labels according to the provided xml" do
      @fetched.labels.should == ['test', 'label']
    end

    it "Populates the property value based on the provided xml" do
      @fetched.property.should == 'Inbox'
    end
  end
end