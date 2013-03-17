shared_examples_for :google_client do
  describe '#new' do
    it "assigns the domain used in constructing URLs" do
      client.domain.should == "example.com"
    end
  end

  describe "#make_request" do
    it "should make a GET request" do
      stub = stub_request(:get, "http://someurl.com/some_path/").with(:headers => {'content-type' => 'custom/format'})
      client.make_request(:get, 'http://someurl.com/some_path/', headers: {'content-type' => 'custom/format'})
      stub.should have_been_requested
    end

    it "should make a POST request" do
      stub = stub_request(:post, "http://someurl.com/some_path/").with(body: "Some body to love")
      client.make_request(:post, 'http://someurl.com/some_path/', body: "Some body to love")
      stub.should have_been_requested
    end

    it "should make a PUT request" do
      stub = stub_request(:put, "http://someurl.com/some_path/").with(body: "Some body to love")
      client.make_request(:put, 'http://someurl.com/some_path/', body: "Some body to love")
      stub.should have_been_requested
    end

    it "should make a DELETE request" do
      stub = stub_request(:delete, "http://someurl.com/some_path/").with(:headers => {'foo' => 'bar'})
      client.make_request(:delete, 'http://someurl.com/some_path/', :headers => {'foo' => 'bar'})
      stub.should have_been_requested
    end

    [401, 403, 404, 500, 501, 503].each do |error_code|
      it "should raise if the response is a #{error_code}" do
        stub_request(:get, "http://someurl.com/some_path/").to_return(:status => error_code)
        expect { client.make_request(:get, 'http://someurl.com/some_path/') }.to raise_exception
      end
    end

    [200, 201, 202, 203].each do |ok_code|
      it "should not raise if the response is a #{ok_code}" do
        stub_request(:get, "http://someurl.com/some_path/").to_return(:status => ok_code)
        expect { client.make_request(:get, 'http://someurl.com/some_path/') }.to_not raise_exception
      end
    end
  end
end