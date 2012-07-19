require 'spec_helper'

describe "GoogleApps::AppsRequest" do
  let (:request) { GoogleApps::AppsRequest.new :get, 'http://www.google.com', test: 'bob' }

  describe "#send_request" do
    it "Sends the request as configured" do
      request.send_request.should be_a Net::HTTPResponse
    end
  end

  describe "#add_body" do
    it "Adds the specified content to the request body" do
      request.add_body 'test'

      request.instance_eval { @http_request.body }.should == 'test'
    end
  end

  describe "#initialize_http" do
    before(:all) do
      @get = build_request :get
      @put = build_request :put
      @post = build_request :post
      @delete = build_request :delete
    end

    it "Creates a Net::HTTP::Get object when passed 'get'" do
      @get.instance_eval { @http_request }.should be_a Net::HTTP::Get
    end

    it "Creates a Net::HTTP::Put object when passed 'put'" do
      @put.instance_eval { @http_request }.should be_a Net::HTTP::Put
    end

    it "Creates a Net::HTTP::Post object when passed 'post'" do
      @post.instance_eval { @http_request }.should be_a Net::HTTP::Post
    end

    it "Creates a Net::HTTP::Delete object when passed 'delete'" do
      @delete.instance_eval { @http_request }.should be_a Net::HTTP::Delete
    end

    it "Sets the uri according to the given argument" do
      request.instance_eval { @uri.host }.should == 'www.google.com'
    end
  end

  describe "#build_constant" do
    it "Takes the given verb and returns the namespaced constant for that type of HTTP class" do
      request.send(:build_constant, :put).to_s.should == 'Net::HTTP::Put'
    end
  end

  describe "#set_headers" do
    it "Sets the headers on @http_request" do
      request.send(:set_headers, :'content-type' => 'application/x-www-form-urlencoded')

      request.instance_eval { @http_request['content-type'] }.should == 'application/x-www-form-urlencoded'
    end
  end
end