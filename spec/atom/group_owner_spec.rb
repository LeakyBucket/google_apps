require 'spec_helper'

describe "GoogleApps::Atom::GroupOwner" do
  let (:owner) { GoogleApps::Atom::GroupOwner.new }

  describe "#add_address" do
    it "adds the email property to the document" do
      owner.add_address 'lholcomb2@cnm.edu'

      owner.to_s.should include 'name="email"'
      owner.to_s.should include 'value="lholcomb2@cnm.edu"'
    end
  end

  describe "#address=" do
    it "Sets @address if not set" do
      owner.address = 'tim@bob.com'

      owner.address.should == 'tim@bob.com'
    end

    it "Adds the property node if not present" do
      owner.address = 'tim@bob.com'

      owner.to_s.should include 'value="tim@bob.com"'
    end

    it "Updates @address if already set" do
      owner.address = 'tim@bob.com'
      owner.address = 'steve@dave.com'

      owner.address.should == 'steve@dave.com'
    end

    it "Updates the property node if already present" do
      owner.address = 'tim@bob.com'
      owner.address = 'steve@dave.com'

      owner.to_s.should include 'value="steve@dave.com'
      owner.to_s.should_not include 'value="tim@bob.com"'
    end
  end
end