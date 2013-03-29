require 'base64'
require 'cgi'
require 'libxml'
require 'oauth'
require 'openssl'
require 'rest_client'
require 'rexml/document'

require 'google_apps/atom/atom'
require 'google_apps/atom/node'
require 'google_apps/atom/document'
require 'google_apps/document_handler'
require 'google_apps/atom/feed'
require 'google_apps/atom/user'
require 'google_apps/atom/group'
require 'google_apps/atom/public_key'
require 'google_apps/atom/export'
require 'google_apps/atom/message_attributes'
require 'google_apps/atom/group_member'
require 'google_apps/atom/nickname'
require 'google_apps/atom/group_owner'
require 'google_apps/provisioning_api/user'

require 'google_apps/client'
require 'google_apps/hybrid_auth_client'
require 'google_apps/oauth2_client'
require 'google_apps/client_login'

class GoogleApps
  def self.client=(val)
    @@client = val
  end

  def self.client
    @@client
  end
end