require 'spec_helper'

describe "GoogleApps::Atom::Nickname" do
  let (:nick) { GoogleApps::Atom::Nickname.new }

  describe "#new" do
    it "Initializes the document header" do
      nick.document.to_s.should include '<?xml version="1.0" encoding="UTF-8"?>'
    end

    it "Initializes an XML document" do
      nick.document.should be_a LibXML::XML::Document
    end
  endcaj

  describe "#to_s" do
    it "Returns @document as a string" do
      nick.to_s.should be_a String
      nick.to_s.should == nick.document.to_s
    end
  end

  describe "#nickname=" do
    it "Sets the nickname attribute on the document" do
      nick.nickname = 'Bob'

      nick.to_s.should include 'apps:nickname name="Bob"'
    end

    it "Sets the nickname value in the object" do
      nick.nickname = 'Tom'

      nick.nickname.should == 'Tom'
    end

    it "Changes the value of the nickname attribute if nickname is already set" do
      nick.nickname = 'Lou'
      nick.nickname = 'Al'

      nick.to_s.should include 'apps:nickname name="Al"'
      nick.to_s.should_not include 'apps:nickname name="Lou"'
    end
  end

  describe "#user=" do
    it "Sets the username attribute on the document" do
      nick.user = 'tim@joe.com'

      nick.to_s.should include 'apps:login userName="tim@joe.com"'
    end

    it "Sets the username value in the object" do
      nick.user = 'jimmy@jim.com'

      nick.user.should == 'jimmy@jim.com'
    end

    it "Changes the value of the apps:login element if user is already set" do
      nick.user = 'lou@bob'
      nick.user = 'tom@bob'

      nick.to_s.should include 'apps:login userName="tom@bob"'
      nick.to_s.should_not include 'apps:login userName="lou@bob"'
    end
  end
end