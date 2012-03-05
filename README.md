# Google Apps API

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
    * Groups
      * Group Creation
      * Group Deletion
  * Public Key Upload
  * Email Audit
    * Mailbox Export Request
    * Mailbox Export Status Check
    * Mailbox Export Download
  * Email Migration
    * Message Upload
    * Sett Message Attributes


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
  * Groups Settings (Modification only)
  * Provisioning (Modification only)
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
user.new_user 'bob', 'Bob', 'Jenkins', 'password', 2048

transporter.new_user user


# Deleting a User
transporter.delete_user 'bob'


# Creating a Group
group = GoogleApps::Atom::Group.new
group.new_group id: 'ID', name: 'TestGroup', description: 'Simple Test Group', perms: 'Domain'

transporter.new_group group


# Deleting a Group
transporter.delete_group 'ID'


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