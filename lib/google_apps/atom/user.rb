module GoogleApps
	module Atom
  	class User
      attr_reader :document
      
  		def initialize
  			@document = Atom::XML::Document.new
  			add_header
  		end

  		def new_user(user_name, first, last, password, quota=nil)
        new_doc
        add_header
  			@document.root << login_node(user_name, password)
  			@document.root << quota_node(quota) if quota
  			@document.root << name_node(first, last)

        @document
  		end

      def new_doc
        @document = Atom::XML::Document.new
      end

  		def login_node(user_name, password)
  			login = Atom::XML::Node.new('apps:login')
  			login['userName'] = user_name
  			login['password'] = Digest::SHA1.hexdigest password
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

      def to_s
        @document.to_s
      end

      private

      def add_header
        @document.root = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(@document.root, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(@document.root, 'apps', 'http://schemas.google.com/apps/2006')

        category = Atom::XML::Node.new('atom:category')
        category.attributes['scheme'] = 'http://schemas.google.com/g/2005#kind'
        category.attributes['term'] = 'http://schemas.google.com/apps/2006#user'

        @document.root << category
      end
  	end
  end
end