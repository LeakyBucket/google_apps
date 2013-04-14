require 'spec_helper'

class GoogleApps
  module ProvisioningApi

    describe User do
      before { GoogleApps.client = Klient.new('example.com') }

      describe ".find" do
        context 'when the user is found' do
          before do
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/sjones").
              to_return(:status => 200, :body => File.read('spec/fixture_xml/user_response.xml'))
          end

          it 'returns the user' do
            user = User.find('sjones')
            user.should be_a(User)
            user.login.should == 'sjones'
            user.first_name.should == "Susan"
            user.last_name.should == "Jones"
            user.storage_quota.should == 25600
            user.should_not be_suspended
            user.should_not be_admin
          end
        end

        context 'when the user is not found' do
          before do
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/not-found-user").
              to_return(:status => 404)
          end

          it 'returns nil' do
            user = User.find('not-found-user')
            user.should be_nil
          end
        end
      end

      describe ".delete" do
        it 'returns true when the request is successful' do
          delete_request = stub_request(:delete, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/sjones").
            to_return(:status => 200)
          User.delete('sjones').should be_true
          delete_request.should have_been_requested
        end

        it 'returns false when the request fails' do
          delete_request = stub_request(:delete, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/sjones").
            to_return(:status => 400)
          User.delete('sjones').should be_false
          delete_request.should have_been_requested
        end
      end

      describe ".all" do
        context 'when there are users' do
          before do
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
              to_return(:status => 200, :body => File.read('spec/fixture_xml/users_response.xml'))
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0?startUsername=stevieb").
              to_return(:status => 200, :body => File.read('spec/fixture_xml/users_response_page_2.xml'))
          end

          it 'returns an array of users across pages' do
            users = User.all
            users.count.should == 4
            users.first.should be_a(User)
          end
        end
      end

      describe ".create" do
        let (:user_doc) {
          File.read("spec/fixture_xml/user_create.xml")
        }

        it "returns a user on successful POST" do

          stub_request(:post, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
            with(headers: {'Content-type' => 'application/atom+xml'}) { |request|
            doc = REXML::Document.new(request.body)
            begin
              doc.elements['//apps:login'].attribute('userName').value == 'sjones' &&
                doc.elements['//apps:login'].attribute('password').value == Digest::SHA1.hexdigest('foo') &&
                doc.elements['//apps:login'].attribute('suspended').value == 'false' &&
                doc.elements['//apps:name'].attribute('givenName').value == 'Susan' &&
                doc.elements['//apps:name'].attribute('familyName').value == 'Jones'
            end
          }.to_return(status: 200, body: File.read('spec/fixture_xml/user_response.xml'))

          user = User.create(login: 'sjones',
                             password: 'foo',
                             first_name: 'Susan',
                             last_name: 'Jones',
                             suspended: false
          )

          user.login.should == 'sjones'
          user.first_name.should == 'Susan'
          user.last_name.should == 'Jones'
          user.should_not be_suspended
        end

        it "returns nil on unsuccessful POST" do
          stub_request(:post, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
            to_return(status: 400)
          User.create(login: 'sjones@example.com').should be_nil
        end
      end

      describe '.update' do
        let (:user_doc) {
          File.read("spec/fixture_xml/user_create.xml")
        }

        it "returns an updated user on successful PUT" do

          stub_request(:put, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/sjones").
            with(headers: {'Content-type' => 'application/atom+xml'}) { |request|
            doc = REXML::Document.new(request.body)
            begin
              doc.elements['//apps:login'].attribute('userName').value == 'sstevens' &&
                doc.elements['//apps:login'].attribute('password').value == Digest::SHA1.hexdigest('foo2') &&
                doc.elements['//apps:login'].attribute('suspended').value == 'true' &&
                doc.elements['//apps:name'].attribute('givenName').value == 'Susie' &&
                doc.elements['//apps:name'].attribute('familyName').value == 'Stevens'
            end
          }.to_return(status: 200, body: File.read('spec/fixture_xml/user_update_response.xml'))

          user = User.update('sjones',
                             login: 'sstevens',
                             password: 'foo2',
                             first_name: 'Susie',
                             last_name: 'Stevens',
                             suspended: true
          )

          user.login.should == 'sstevens'
          user.first_name.should == 'Susie'
          user.last_name.should == 'Stevens'
          user.should be_suspended
        end

        it "returns nil on unsuccessful PUT" do
          stub_request(:put, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/zoo").
            to_return(status: 400)
          User.update('zoo', login: 'new_zoo').should be_nil
        end
      end
    end
  end
end