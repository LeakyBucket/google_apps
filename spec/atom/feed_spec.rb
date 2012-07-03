require 'spec_helper'

describe "GoogleApps::Atom::Feed" do
  let (:xml) { File.read('spec/feed.xml') }
  let (:feed) { GoogleApps::Atom::Feed.new xml }

  describe "#new" do
    it "Parses the given xml" do
      feed.xml.should be_a LibXML::XML::Document
    end

    it "Populates @items with Atom objects of the proper type" do
      feed.items.first.should be_a GoogleApps::Atom::User
    end
  end

  describe "#entries_from" do
    it "Builds an array of Atom objects" do # We have a bad regex somewhere, User doesn't work as an argument
      results = feed.entries_from document: feed.xml, type: 'Users', entry_tag: 'entry'

      results.first.should be_a GoogleApps::Atom::User
    end
  end

  describe "#new_doc_with_entry" do
    it "Returns a document with an apps:entry element" do
      feed.new_doc_with_entry('user').to_s.should include '<apps:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:apps="http://schemas.google.com/apps/2006"/>'
    end
  end
end