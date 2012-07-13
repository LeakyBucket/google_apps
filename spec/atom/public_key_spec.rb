require 'spec_helper'

describe "GoogleApps::Atom::PublicKey" do
  let (:pub_key) { GoogleApps::Atom::PublicKey.new }
  let (:key) { 'not really a key' }

  describe "#new" do
    it "Initializes @document to be a LibXML::XML::Document" do
      pub_key.document.should be_a LibXML::XML::Document
    end

    it "Adds the root node to @document" do
      pub_key.to_s.should include '<atom:entry'
      pub_key.to_s.should include 'xmlns:atom'
      pub_key.to_s.should include 'xmlns:apps'
    end
  end

  describe "#new_key" do
    it "should add the publicKey property to @document" do
      pub_key.new_key key

      pub_key.to_s.should include 'name="publicKey"'
    end
  end

  describe "#to_s" do
    it "should return @document as a String" do
      pub_key.to_s.should be_a String
    end
  end
end