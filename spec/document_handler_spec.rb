require 'spec_helper'

describe "GoogleApps::DocumentHandler" do
  let (:handler) { GoogleApps::DocumentHandler.new format: :atom }

  describe "#new" do
    it "Sets @format to the format of the document to be processed" do
      handler.format.should == :atom
    end
  end

  describe "#doc_from_string" do
    it "Returns a XML document when given xml and @format is :atom" do
      handler.doc_from_string(finished_export).should be_a LibXML::XML::Document
    end

    it "Returns a XML document when given xml and @format is :xml" do
      handler.format = :xml
      handler.doc_from_string(finished_export).should be_a LibXML::XML::Document
    end
  end

  describe "#format=" do
    it "Changes the format" do
      handler.format = :xml

      handler.format.should == :xml
    end

    it "Rebuilds the @documents list" do
      handler.format = :xml

      handler.instance_eval { @documents }.should == GoogleApps::Atom::DOCUMENTS
    end
  end

  describe "#look_up_doc_types" do
    it "Returns a list of all Atom documents when @format is :atom" do
      handler.send(:look_up_doc_types).should == GoogleApps::Atom::DOCUMENTS
    end

    it "Returns a list of all Atom documents when @format is :xml" do
      handler.format = :xml
      handler.send(:look_up_doc_types).should == GoogleApps::Atom::DOCUMENTS
    end
  end

  describe "#set_format" do
    it "Sets @format to the given value" do
      handler.send(:set_format, :xml)

      handler.format.should == :xml
    end

    it "Sets the @document list" do
      handler.send(:set_format, :xml)

      handler.instance_eval { @documents }.should == GoogleApps::Atom::DOCUMENTS
    end
  end
end