require 'spec_helper'

describe "GoogleApps::DocumentHandler" do
  let (:handler) { GoogleApps::DocumentHandler.new format: :atom }

  describe "#new" do
    it "Sets @type to the type of document to be processed" do
      handler.format.should == :atom
    end

    it "Includes the proper modules based on @type"
  end

  describe "#doc_from_string" do
    it "Returns a document of the given type using the given string"
  end
end