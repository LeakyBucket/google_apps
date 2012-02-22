require 'spec_helper'

describe "GoogleApps::Atom::Export" do
  let (:export) { GoogleApps::Atom::Export.new }
  let (:start) { '2012-2-20 00:00' }
  let (:finish) { '2012-2-22 00:00' }
  let (:query) { 'from:webmaster' }
  let (:content) { 'HEADER_ONLY' }

  describe "#new" do
    it "should initialize @document to an XML::Document" do
      export.instance_eval { @document }.should be_a LibXML::XML::Document
    end
  end

  describe "#to_s" do
    it "should return @document as a String" do
      export.to_s.should be_a String
    end
  end

  describe "#add_prop" do
    it "should add a property with the given name and value to the document" do
      export.send :add_prop, 'food', 'bacon'

      export.to_s.should include 'name="food"'
      export.to_s.should include 'value="bacon"'
    end
  end

  describe "#start_date" do
    it "should add a beginDate property to the export document" do
      export.start_date start

      export.to_s.should include 'name="beginDate"'
    end
  end

  describe "#end_date" do
    it "should add an endDate property to the export document" do
      export.end_date finish

      export.to_s.should include 'name="endDate"'
    end
  end

  describe "#search_deleted" do
    it "should add an includeDeleted property to the document" do
      export.search_deleted(true)

      export.to_s.should include 'name="includeDeleted"'
    end
  end

  describe "#query" do
    it "should add a searchQuery property to the document" do
      export.query query

      export.to_s.should include 'name="searchQuery"'
    end
  end

  describe "#content" do
    it "should add a packageContent property to the document" do
      export.content content

      export.to_s.should include 'name="packageContent"'
    end
  end
end