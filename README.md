# Google Apps API

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/LeakyBucket/google_apps)

## What is this?

This is another GoogleApps API Library.  I know there is one floating around out there but it is 2 years old and doesn't claim to do more than: users, groups, and calendar.

The goal here is a library that supports the entire GoogleApps Domain and Applications APIs.

#### Currently Supported:

__Domain API__

  * Authentication
  * Provisioning
    * Users
      * User Creation
      * User Deletion
      * User Record Retrieval
      * User Modification
      * Retrieve all users in the domain
    * Groups
      * Group Creation
      * Group Deletion
      * Group Record Retrieval
      * Add Group Member
      * Delete Group Member
      * Modify Group Attributes
    * Nicknames
      * Creation
      * Deletion
      * List Nicknames for a User
  * Public Key Upload
  * Email Audit
    * Mailbox Export Request
    * Mailbox Export Status Check
    * Mailbox Export Download
  * Email Migration
    * Message Upload
    * Set Message Attributes


#### TODO:

__Domain__

  * Admin Audit
  * Admin Settings
  * Calendar Resource
  * Domain Shared Contacts
  * Email Audit
    * Email Monitors
    * Account Information
  * Email Settings
  * Groups Settings
    * Member List
  * Reporting
  * Reporting Visualization
  * User Profiles

__Application__

  * Calendar Data
  * Contacts Data
  * Documents List Data
  * Sites Data
  * Spreadsheets Data
  * Tasks

## Short How

~~~~~
gem install google_apps
~~~~~

~~~~~
require 'google_apps'

transporter = GoogleApps::Transport.new 'domain'
transporter.authenticate 'username@domain', 'password'


# Creating a User
user = GoogleApps::Atom::User.new
# or
user = GoogleApps::Atom.user

user.set login: 'JWilkens', password: 'uncle J', first_name: 'Johnsen', last_name: 'Wilkens'

transporter.new_user user


# Modifying a User
user = GoogleApps::Atom::User.new
user.last_name = 'Johnson'
user.suspended = true

transporter.update_user 'bob', user


# Deleting a User
transporter.delete_user 'bob'


# Retrieving a User
transporter.get_user 'bob'

transporter.response.body


# Retrieving all Users
# User feed access is clunky and needs to be simplified
transporter.get_users

transporter.feeds.each do |feed|
  feed.items.each do |user|
    puts user.login
  end
end


# Retrieving a range of Users
# Again this needs to be prettified
transporter.get_users start: 'lholcomb2', limit: 320

transporter.feeds.each do |feed|
  feed.items.each do |user|
    puts user.login
  end
end


# Creating a Group
group = GoogleApps::Atom::Group.new
group.new_group id: 'ID', name: 'TestGroup', description: 'Simple Test Group', perms: 'Domain'

transporter.new_group group


# Modifying a Group
group = GoogleApps::Atom::Group.new
group.set_values name: 'New Name'

transporter.update_group 'target_group', group


# Adding a Member to a Group
group_member = GoogleApps::Atom::GroupMember.new
group_member.member = 'Bob'

transporter.add_member_to 'target_group', group_member


# Seleting a Member from a Group
transporter.delete_member_from 'target_group', 'member_id'


# Deleting a Group
transporter.delete_group 'ID'


# Retrieving all the Groups in the Domain
transporter.get_groups

transporter.feeds.each do |feed|
  feed.items.each do |group|
    puts group.to_s
  end
end


# Creating a Nickname
nick = GoogleApps::Atom::Nickname.new
nick.nickname = 'Nickname'
nick.user = 'username'

transporter.add_nickname nick


# Retrieving a Nickname
transporter.get_nickname 'Nickname'


# Deleting a Nickname
transporter.delete_nickname 'Nickname'


# Uploading Public Key
pub_key = GoogleApps::Atom::PublicKey.new
pub_key.new_key File.read('key_file')

transporter.add_pubkey pub_key


# Request Mailbox Export
export_req = GoogleApps::Atom::Export.new
export_req.query 'from:Bob'
export_req.content 'HEADER_ONLY'

transporter.request_export 'username', export_req


# Check Export Status
transporter.export_status 'username', 'req_id'


# Download Export
transporter.fetch_export 'username', 'req_id', 'filename'


# Migrate Email
attributes = GoogleApps::Atom::MessageAttributes.new
attributes.add_label 'Migration'

transporter.migrate 'username', attributes, message
~~~~~

## Long How

#### GoogleApps::Transport

This is the main piece of the library.  The Transport class does all the heavy lifting and communication between your code and the Google Apps Envrionment.  

Transport will accept a plethora of configuration options.  However most have currently sane defaults.  In particular the endpoint values should default to currently valid URIs.  

The only required option is the name of your domain:

~~~~
GoogleApps::Transport.new 'cnm.edu'
~~~~

This domain value is used to set many of the defaults, which are:

  * @auth - The default base URI for auth requests (This will change once OAuth support is added).
  * @user - The default base URI for user related API requests.
  * @pubkey - The default base URI for public key related API requests.
  * @migration - The default base URI for email migration related API requests.
  * @group - The default base URI for group related API requests.
  * @nickname - The default base URI for nickname related API requests.
  * @export - The default base URI for mail export related API requests.
  * @requester - The class to use for making API requests, the default is GoogleApps::AppsRequest
  * @doc_handler - The doc_handler parses Google Apps responses and returns the proper document object.  The default format is :atom, you can specify a different format by passing format: <format> during Transport instantiation.

GoogleApps::Transport is your interface for any HTTP verb related action.  It handles GET, PUT, POST and DELETE requests.  Transport also provides methods for checking the status of long running requests and downloading content.


### GoogleApps::Atom::User

This class represents a user record in the Google Apps Environment.  It is basically a glorified LibXML::XML::Document.  

User provides a basic accessor interface for common attributes.  It also provides methods for setting and updating less common nodes.  

