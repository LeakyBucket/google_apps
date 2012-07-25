require 'spec_helper'

describe "GoogleApps::DocumentHandler" do
  let (:handler) { GoogleApps::DocumentHandler.new type: :atom }

  describe "#new" do
    it "Sets @type to the type of document to be processed" do
      handler.type.should == :atom
    end

    it "Includes the proper modules based on @type"
  end
end