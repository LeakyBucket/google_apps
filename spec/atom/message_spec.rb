require 'spec_helper'

describe "GoogleApps::Atom::Message" do
  let (:message) { GoogleApps::Atom::Message.new }
  let (:content) { "This is the body of the email message.  Would you like to have lunch this week?" }

  describe "#new" do
    it "should initialize @document to an XML::Document" do
      message.instance_eval { @document }.should be_a LibXML::XML::Document
    end
  end

  describe "#from" do
    before do
      File.open('./file', 'w') do |file|
        file.puts content
      end
    end

    it "should create an apps:rfc822Msg document" do
      message.from './file'

      message.to_s.should include 'lunch'
    end
  end

  describe "#to_s" do
    it "should return @document as a String" do
      message.to_s.should be_a String
    end
  end
end