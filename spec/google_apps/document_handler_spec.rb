require 'spec_helper'

describe "GoogleApps::DocumentHandler" do
  let (:handler) { GoogleApps::DocumentHandler.new format: :atom }
  let (:documents) { to_meth GoogleApps::Atom::Document.types }

  describe "#new" do
    it "Sets @format to the format of the document to be processed" do
      handler.format.should == :atom
    end
  end

  describe "#create_doc" do
    it "Returns a XML document when given xml and @format is :atom" do
      handler.create_doc(finished_export, :export).should be_a LibXML::XML::Document
    end

    it "Returns a XML document when given xml and @format is :xml" do
      handler.format = :xml
      handler.create_doc(finished_export, :export).should be_a LibXML::XML::Document
    end

    xit "Returns a document of the given type if specified" do
      handler.create_doc(File.read('spec/fixture_xml/user.xml'), :user).should be_a GoogleApps::Atom::User
    end
  end

  describe "#unknown_type" do
    it "Returns an XML Document when given a string and @format is :atom" do
      handler.unknown_type(finished_export).should be_a LibXML::XML::Document
    end

    it "Returns an XML Document when given a string and @format is :xml" do
      handler.unknown_type(finished_export).should be_a LibXML::XML::Document
    end
  end

  describe "#format=" do
    it "Changes the format" do
      handler.format = :xml

      handler.format.should == :xml
    end

    it "Rebuilds the @documents list" do
      handler.format = :xml

      handler.instance_eval { @documents }.should == documents
    end
  end

  describe "#doc_of_type" do
    it "Returns an object of the specified type if the type is valid for the format" do
      user = handler.doc_of_type File.read('spec/fixture_xml/user.xml'), :user

      user.should be_a GoogleApps::Atom::User
    end

    it "Raises a RuntimeError if the type is not valid for the format" do
      lambda { handler.doc_of_type :goat, File.read('spec/fixture_xml/user.xml') }.should raise_error
    end
  end

  describe "#look_up_doc_types" do
    it "Returns a list of all Atom documents when @format is :atom" do
      handler.send(:look_up_doc_types).should == documents
    end

    it "Returns a list of all Atom documents when @format is :xml" do
      handler.format = :xml
      handler.send(:look_up_doc_types).should == documents
    end
  end

  describe "#set_format" do
    it "Sets @format to the given value" do
      handler.send(:set_format, :xml)

      handler.format.should == :xml
    end

    it "Sets the @document list" do
      handler.send(:set_format, :xml)

      handler.instance_eval { @documents }.should == documents
    end
  end
end