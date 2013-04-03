require 'spec_helper'

class GoogleApps
  module ProvisioningApi

    describe User do
      before { GoogleApps.client = Klient.new('example.com') }

      describe ".find" do
        context 'when the user is found' do
          before do
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0/mmcfly").
                to_return(:status => 200, :body => File.read('spec/fixture_xml/user_response.xml'))
          end

          it 'returns the user' do
            user = User.find('mmcfly')
            user.should be_a(User)
            user.login.should == 'mmcfly'
            user.first_name.should == "Marty"
            user.last_name.should == "McFly"
            user.storage_quota.should == 25600
            user.should_not be_suspended
            user.should be_admin
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

      describe ".all" do
        context 'when there are users' do
          before do
            stub_request(:get, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
                to_return(:status => 200, :body => File.read('spec/fixture_xml/users_response.xml'))
          end

          it 'returns an array of users' do
            users = User.all
            users.count.should == 2
            users.first.should be_a(User)
          end
        end
      end

      describe ".create" do
        describe '#add_user' do
          let (:user_doc) {
            <<-XML
<atom:entry xmlns:atom='http://www.w3.org/2005/Atom'
            xmlns:apps='http://schemas.google.com/apps/2006'>
  <apps:property name="password" value="zonkey"/>
  <apps:property name="hashFunction" value="SHA-1"/>
  <apps:property name="userEmail" value="liz@example.com"/>
  <apps:property name="firstName" value="Liz"/>
  <apps:property name="lastName" value="Smith"/>
  <apps:property name="isAdmin" value="true"/>
  <apps:property name="isSuspended" value="false"/>
</atom:entry>
            XML
          }

          it "returns a user on successful POST" do

            stub_request(:post, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
                with(:body => user_doc, headers: {'Content-type' => 'application/atom+xml'}).
                to_return(status: 200, body: File.read('spec/fixture_xml/user_response.xml'))
            user = User.create(email: 'liz@example.com',
                        password: 'zonkey',
                        first_name: 'Liz',
                        last_name: 'Smith',
                        admin: true,
                        suspended: false
            )

            user.login.should == 'mmcfly'
            #user.password.should be_hashed
            user.first_name.should == 'Marty'
            user.last_name.should == 'McFly'
            user.should be_admin
            user.should_not be_suspended
          end

          it "returns nil on unsuccessful POST" do
            stub_request(:post, "https://apps-apis.google.com/a/feeds/example.com/user/2.0").
                to_return(status: 404)
            User.create(email: 'liz@example.com')
          end
        end
      end
    end

  end
end