require 'spec_helper'

describe GoogleApps::HybridAuthClient do
  let(:client) { GoogleApps::HybridAuthClient.new(domain: 'example.com', google_app_id: 'some-app-id', google_app_secret: 'some-app-secret') }

  it_should_behave_like :google_client

  it "sets the right auth headers for Hybrid OpenID/OAuth" do
    oauth_regex = /OAuth oauth_consumer_key=".+?", oauth_nonce=".+?", oauth_signature=".+?", oauth_signature_method="HMAC-SHA1", oauth_timestamp=".+?", oauth_version="1\.0"/
    stub = stub_request(:get, "http://someurl.com/path/").with { |request|
      request.headers['Authorization'] =~ oauth_regex && request.headers['Gdata-Version'] == '2.0'
    }
    client.make_request(:get, 'http://someurl.com/path/')
    stub.should have_been_requested
  end
end