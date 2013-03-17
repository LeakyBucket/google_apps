require 'spec_helper'

describe GoogleApps::Oauth2Client do
  let(:client) { GoogleApps::Oauth2Client.new(domain: 'example.com', token: 'some-token') }

  it_should_behave_like :google_client

  it "sets the right auth headers for OAuth2" do
    stub = stub_request(:get, "http://someurl.com/").with(:headers => {'Authorization' => 'OAuth some-token'})
    client.make_request(:get, 'http://someurl.com')
    stub.should have_been_requested
  end
end