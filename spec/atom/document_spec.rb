require 'spec_helper'

describe "GoogleApps::Atom::Document" do
  let (:doc_container) { class Doc; include GoogleApps::Atom::Document; end }
  let (:document) { doc_container.new }
  let (:doc_string) { File.read('spec/test_doc.xml') }

  describe "#parse" do
    it "parses the given XML document" do
      document.parse(doc_string).should be_a LibXML::XML::Document
    end
  end

  describe "#make_document" do
    it "turns the input into an LibXML::XML::Document" do
      document.make_document(doc_string).should be_a LibXML::XML::Document
    end
  end

  describe "#new_empty_doc" do
    it "Returns a new empty LibXML::XML::Document" do
      new_doc = document.new_empty_doc

      new_doc.should be_a LibXML::XML::Document
      new_doc.to_s.strip.should == '<?xml version="1.0" encoding="UTF-8"?>'
    end
  end

  describe "#build_root" do
    it "Builds an atom:entry XML Node with the appropriate namespaces" do
      
    end

    it "Builds an atom:entry XML Node containing a category element" do
      
    end

    it "Builds an atom:entry XML Node containing a category element of the right kind" do
      
    end
  end

  describe "#type_to_s" do
    it "Returns the document type (class) as a string" do
      document.type_to_s.should == 'doc'
    end
  end

  describe "#type_to_sym" do
    it "Returns the document type (class) as a symbol" do
      document.type_to_sym.should == :doc
    end
  end

  describe "#determine_namespaces" do
    it "Builds a hash of the appropriate namespaces" do
      ns = document.determine_namespaces

      ns[:atom].should == GoogleApps::Atom::NAMESPACES[:atom]
      ns[:apps].should == GoogleApps::Atom::NAMESPACES[:apps]
    end
  end
end