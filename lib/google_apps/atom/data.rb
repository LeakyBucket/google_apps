require 'libxml'

module GoogleApps
	module Atom
  	include LibXML
  	HASH_FUNCTION = "SHA-1"

  	class User
      attr_reader :document
      
  		def initialize
  			@document = Atom::XML::Document.new
  			add_header
  		end

  		def add_header
  			@document.root = Atom::XML::Node.new('atom:entry')

  			Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
  			Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')

  			category = Atom::XML::Node.new('atom:category')
  			category.attributes['scheme'] = 'http://schemas.google.com/g/2005#kind'
  			category.attributes['term'] = 'http://schemas.google.com/apps/2006#user'

  			@document.root << category
  		end

  		def new_user(user_name, first, last, password, quota)
  			@document.root << login_node(user_name, password)
  			@document.root << quota_node(quota)
  			@document.root << name_node(first, last)

        @document
  		end

  		def login_node(user_name, password)
  			login = Atom::XML::Node.new('apps:login')
  			login['userName'] = user_name
  			login['password'] = password
  			login['hashFunctionName'] = Atom::HASH_FUNCTION
  			login['suspended'] = "false"

  			login
  		end

  		def quota_node(limit)
  			quota = Atom::XML::Node.new('apps:quota')
  			quota['limit'] = limit.to_s

  			quota
  		end

  		def name_node(first, last)
  			name = Atom::XML::Node.new('apps:name')
  			name['familyName'] = last
  			name['givenName'] = first

  			name
  		end
  	end

  	class Group
  		def initialize
  			@document = Atom::XML::Document.new
  		end
  	end
  end
end