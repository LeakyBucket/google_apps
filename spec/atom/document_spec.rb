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
end