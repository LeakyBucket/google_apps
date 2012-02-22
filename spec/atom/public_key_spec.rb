require 'spec_helper'

describe "GoogleApps::Atom::PublicKey" do
  let (:pub_key) { GoogleApps::Atom::PublicKey.new }
  let (:key) { `cat ../pub_key` }

  describe "#add_header" do
    it "should ad the proper header to @document" do
      pub_key.send :add_header

      doc = pub_key.to_s

      doc.should include 'xmlns:apps'
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