require 'spec_helper'

describe GoogleApps::ClientLogin do
  let(:client) { GoogleApps::ClientLogin.new(domain: 'example.com') }

  before do
    stub_request(:post, "https://www.google.com/accounts/ClientLogin").
        with(:body => {"Email" => "joe@example.com", "Passwd" => "p4ssw0rd", "accountType" => "HOSTED", "service" => "apps"},
             :headers => {'Content-Type' => 'application/x-www-form-urlencoded'}).
        to_return(body: "auth=best-token-ever")
    client.authenticate!('joe@example.com', 'p4ssw0rd')
  end

  it_should_behave_like :google_client

  it "sets the right auth headers for ClientLogin" do
    stub = stub_request(:get, "http://someurl.com/path/").
        with(:headers => {'Authorization' => 'GoogleLogin auth=best-token-ever'})
    client.make_request(:get, 'http://someurl.com/path/')
    stub.should have_been_requested
  end
end