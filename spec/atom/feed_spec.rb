require 'spec_helper'

describe "GoogleApps::Atom::Feed" do
  let (:xml) { File.read('spec/feed.xml') }
  let (:feed) { GoogleApps::Atom::Feed.new xml }
  let (:content_array) { ['<apps:login userId="Mom"/>', '<apps:quota value="80"/>', '<id/>', '<atom:category/>'] }

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

  describe "#new_doc" do
    it "Returns a new Atom Document with the desired elements" do
      doc = feed.new_doc 'user', content_array, ['apps:']

      doc.to_s.should include '<apps:login'
      doc.to_s.should include '<apps:quota'
      doc.to_s.should_not include '<gd:category'
    end

    it "Returns a new Atom Document with the desired elements when given multiple filters" do
      doc = feed.new_doc 'user', content_array, ['apps:', 'atom:']

      doc.to_s.should include '<apps:login'
      doc.to_s.should include '<atom:category'
      doc.to_s.should_not include '<id'
    end
  end

  describe "#entry_wrap" do
    it "Wraps the given content in an apps:entry element" do
      entry = feed.entry_wrap(["bob"]).join("\n")

      entry.should include "<atom:entry xmlns:atom"
      entry.should include "bob"
      entry.should include "</atom:entry>"
    end
  end

  describe "#grab_elements" do
    it "Grabs all elements from the content array matching the filter" do
      matches = feed.grab_elements(content_array, 'apps:')

      matches.each do |match|
        match.should include 'apps:'
      end
    end
  end
end