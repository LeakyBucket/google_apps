require 'spec_helper'

describe GoogleApps::ProvisioningApi::Users do
  let(:client) {Klient.new('example.com')}
  describe "#find_user" do
    context 'when the user is found' do
      before do
        stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/mmcfly").
            to_return(:status => 200, :body => File.read('spec/fixture_xml/user_response.xml'))
      end

      it 'returns the user' do
        user = client.find_user('mmcfly')
        user.should be_a(GoogleApps::User)
        user.login.should == 'mmcfly'
        user.first_name.should == "Marty"
        user.last_name.should == "McFly"
        user.storage_quota.should == 25600
        user.should_not be_suspended
      end
    end

    context 'when the user is not found' do
      before do
        stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/not-found-user").
            to_return(:status => 404)
      end

      it 'returns nil' do
        user = client.find_user('not-found-user')
        user.should be_nil
      end
    end
  end

  describe "#all_users" do
    context 'when there are users' do
      before do
        stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
            to_return(:status => 200, :body => File.read('spec/fixture_xml/users_response.xml'))
      end

      it 'returns an array of users' do
        users = client.all_users
        users.count.should == 2
        users.first.should be_a(GoogleApps::User)
      end
    end
  end
end