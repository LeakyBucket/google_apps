# Google Apps API

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/LeakyBucket/google_apps)


## What is this?

This is another GoogleApps API Library.  It is written for Ruby 1.9.  I know there is one floating around out there but it is 2 years old and doesn't claim to do more than: users, groups, and calendar.

The goal here is a library that supports the entire GoogleApps Domain and Applications APIs.


## Overview
 * [Status](#currently-supported)
 * [Quick and Dirty](#-short-how)
 * [Details](#-long-how)
 * [License](#-license)

## <a id="Status" /> API Coverage

####Currently Supported:

__Domain API__

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
      * Member List
      * Group Owner Management
        * Create Owner
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

## <a id="Brief" /> Short How

Getting and using the library.

```ruby
gem install google_apps

require 'google_apps'
```


Setting up your GoogleApps::Transport object to send requests to Google.

```ruby
transporter = GoogleApps::Transport.new 'domain', 'TOKEN-FROM-OAUTH2-HANDSHAKE'
```


Creating an entity is a matter of creating a matching object and sending it to Google.

```ruby
# Creating a User
user = GoogleApps::Atom::User.new
user = GoogleApps::Atom::User.new <xml string>

# or

user = GoogleApps::Atom.user
user = GoogleApps::Atom.user <xml string>


user.set login: 'JWilkens', password: 'uncle J', first_name: 'Johnsen', last_name: 'Wilkens'

# or

user.login = 'JWilkens'
user.password = 'uncle J'
user.first_name = 'Johnsen'
user.last_name = 'Wilkens'

transporter.new_user user
```


Modifying an entity is also a simple process.

```ruby
# Modifying a User
user.last_name = 'Johnson'
user.suspended = true

transporter.update_user 'bob', user
```


Deleting is extremely light weight.

```ruby
transporter.delete_user 'bob'
```


Getting an entity record from Google.

```ruby
# Retrieving a User
transporter.get_user 'bob'
```


Retrieving a batch of entities from Google.

```ruby
# Retrieving all Users
users = transporter.get_users


# Retrieving a range of Users
users = transporter.get_users start: 'lholcomb2', limit: 320
# Google actually returns records in batches so you will recieve the lowest multiple of 100 that covers your request.
```


Google Apps uses public key encryption for mailbox exports and other audit functionality.  Adding a key is fairly simple.

```ruby
# Uploading Public Key
pub_key = GoogleApps::Atom::PublicKey.new
pub_key.new_key File.read('key_file')

transporter.add_pubkey pub_key
```


Google Apps provides a few mail auditing functions.  One of those is grabbing a mailbox export.  Below is an example.

```ruby
# Request Mailbox Export
export_req = GoogleApps::Atom::Export.new
export_req.query 'from:Bob'
export_req.content 'HEADER_ONLY'

transporter.request_export 'username', export_req
```


Your export request will be placed in a queue and processed eventually.  Luckily you can check on the status while you wait.

```ruby
# Check Export Status
transporter.export_status 'username', <request_id>
transporter.export_ready? 'username', <request_id>
```


Downloading the requested export is simple.

```ruby
# Download Export
transporter.fetch_export 'username', 'req_id', 'filename'
```


The Google Apps API provides a direct migration option if you happen to have email in msg (RFC 822) format.

```ruby
# Migrate Email
attributes = GoogleApps::Atom::MessageAttributes.new
attributes.add_label 'Migration'

transporter.migrate 'username', attributes, File.read(<message>)
```

## <a id="Long" /> Long How

#### GoogleApps::Transport

This is the main piece of the library.  The Transport class does all the heavy lifting and communication between your code and the Google Apps Envrionment.

Transport will accept a plethora of configuration options.  However most have currently sane defaults.  In particular the endpoint values should default to currently valid URIs.

The only required option is the name of your domain and a valid OAuth2 token:

```ruby
GoogleApps::Transport.new 'cnm.edu', 'USERS-OAUTH2-TOKEN'
```

This domain value is used to set up the URIs

GoogleApps::Transport is your interface for any HTTP verb related action.  It handles GET, PUT, POST and DELETE requests.  Transport also provides methods for checking the status of long running requests and downloading content.

### GoogleApps::Atom::User

This class represents a user record in the Google Apps Environment.  It is basically a glorified LibXML::XML::Document.

```ruby
user = GoogleApps::Atom::User.new
user = GoogleApps::Atom::User.new <xml string>

# or

user = GoogleApps::Atom.user
user = GoogleApps::Atom.user <xml string>
```

User provides a basic accessor interface for common attributes.

```ruby
user.login = 'lholcomb2'
# password= will return the plaintext password string but will set a SHA1 encrypted password.
user.password = 'hobobob'
user.first_name = 'Glen'
user.last_name = 'Holcomb'
user.suspended = false
user.quota = 1000


user.login
# => 'lholcomb2'

# password returns the SHA1 hash of the password
user.password
# => 'b8b32c3e5233b4891ae47bd31e36dc472987a7f4'

user.first_name
# => 'Glen'

user.last_name
# => 'Holcomb'

user.suspended
# => false

user.quota
# => 1000
```

It also provides methods for setting and updating less common nodes and attributes.

```ruby
user.update_node 'apps:login', :agreedToTerms, true

# if the user specification were to change or expand you could manually set nodes in the following way.
user.add_node 'apps:property', [['locale', 'Spanish']]
```

GoogleApps::Atom::User also has a to_s method that will return the underlying LibXML::XML::Document as a string.


### GoogleApps::Atom::Group

This class represents a Google Apps Group.  Similarly to GoogleApps::Atom::User this is basically a LibXML::XML::Document.

```ruby
group = GoogleApps::Atom::Group.new
group = GoogleApps::Atom::Group.new <xml string>

# or

group = GoogleApps::Atom.group
group = GoogleApps::Atom.group <xml string>
```

The Group class provides getters and setter for the standard group properties.

```ruby
group.id = 'Group ID'
group.name = 'Example Group'
group.permissions = 'Domain'
group.description = 'A Simple Example'

group.id
# => 'Group ID'
group.name
# => 'Example Group'
group.permissions
# => 'Domain'
group.description
# => 'A Simple Example'
```

*Note:*  Group Membership is actually handled separately in the Google Apps Environment, therefore it is handled separately in this library as well (for now at least). See the next section for Group Membership.


### GoogleApps::Atom::GroupMember

This class is representative of a Google Apps Group Member.

```ruby
member = GoogleApps::Atom::GroupMember.new
member = GoogleApps::Atom::GroupMember.new <xml string>

# or

member = GoogleApps::Atom.group_member
member = GoogleApps::Atom.gorup_member <xml string>
```

A GroupMember really only has one attribute.  The id of the member.

```ruby
member.member = 'bogus_account@cnme.edu'

member.member
# => 'bogus_account@cme.edu'
```

To add a group member you need to make an add_member_to request of your GoogleApps::Transport object.  The method requires the id of the group the member is being added to as well as the member doucument.

```ruby
transporter.add_member_to 'Group ID', member
```

Id's are unique within the Google Apps environment so it is possible to add a group to another group.  You just need to supply the group id as the member value for the GoogleApps::Atom::GroupMember object.


### GoogleApps::Atom::MessageAttributes


The MessageAttributes class represents a Google Apps Message Attribute XML Document.

```ruby
attributes = GoogleApps::Atom::MessageAttributes.new
attributes = GoogleApps::Atom::MessageAttributes.new <xml string>

# or

attributes = GoogleApps::Atom.message_attributes
attributes = GoogleApps::Atom.message_attributes <xml string>
```

This document is sent with an email message that is being migrated.  It tells Google how to store the message.  A Message Attribute object stores the labels for a message along with the "state" or "location" of the message.  Basically along with labels you can specify a message as being in the Inbox, Sent, Drafts, or Trash locations.

You can add labels.

```ruby
attributes.add_label 'Migration'
```

Check labels.

```ruby
attributes.labels
```

And remove labels.

```ruby
attributes.remove_label 'Migration'
```

You can also specify the "Type" of message.  Basically this means you are identifying where it would reside aside from it's labels.  The options are IS_INBOX, IS_SENT, IS_DRAFTS, IS_TRASH, IS_STARRED, IS_UNREAD.

```ruby
attributes.add_property GoogleApps::Atom::MessageAttributes::INBOX
attributes.add_property GoogleApps::Atom::MessageAttributes::SENT
attributes.add_property GoogleApps::Atom::MessageAttributes::DRAFT
attributes.add_property GoogleApps::Atom::MessageAttributes::STARRED
attributes.add_property GoogleApps::Atom::MessageAttributes::UNREAD
attributes.add_property GoogleApps::Atom::MessageAttributes::TRASH

# or

attributes.add_property 'IS_INBOX'
```

Pretty self explainatory with the exception of IS_STARRED if you are not familiar with Google.  Starring is similar to flagging in Exchange.


### GoogleApps::Atom::Nickname

This class represents a Nickname in the Google Apps Environment.

In the Google Apps Environment a Nickname consists of two pieces of information.  A username and the actual nickname.

```ruby
nick.nickname = 'Stretch'
nick.user = 'sarmstrong'
```

Creating a new nickname is pretty simple.

```ruby
transporter.add_nickname nick
```

Nicknames are unique in the scope of your Google Apps Domain so deleting is pretty simple as well.

```ruby
transporter.delete_nickname 'Stretch'
```


### GoogleApps::Atom::PublicKey

As part of the auditing functionality in Google Apps you can request mailbox exports.  Those mailbox exports are encrypted before you can download them.  The PublicKey class facilitates the upload of the key used in that process.

All you need to do is provide a gpg or other key and upload it.

```ruby
pub_key.new_key File.read(key_file)

transporter.new_pubkey pub_key
```


### GoogleApps::Atom::GroupOwner

This is a very lightweight class for the manipulation of group owners in the Google Apps environment.

The Group Owner document only has one value, address.

```ruby
owner.address = 'lholcomb2@root.tld'

transporter.add_owner_to 'example_group@root.tld', owner
```

## <a id="License" /> License

#### MIT