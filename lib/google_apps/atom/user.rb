module GoogleApps
	module Atom
  	class User
      include Atom::Node
      include Atom::Document

      attr_reader :document, :login, :suspended, :first_name, :last_name

  		def initialize(xml = nil)
        if xml
          @document = parse(xml)
          find_values
        else
          @document = new_empty_doc
  			  add_header
        end
  		end

      # new_user adds the nodes necessary to create a new
      # user in Google Apps.  new_user requires a username,
      # first name, last name and password.  You can also
      # provide an optional quota argument, this will override
      # the default quota in Google Apps.
      #
      # new_user 'username', 'first_name', 'last_name', 'password', 1024
      #
      # new_user returns the full XML document.
  		def new_user(user_name, first, last, password, quota=nil)
        set_values suspended: 'false', username: user_name, password: password, first_name: first, last_name: last, quota: quota
  		end

      # TODO: Document
      def set_values(values = {})
        # Don't want to create login_node if nothing has been specified.
        @document.root << login_node(values[:suspended], values[:username], values[:password])
        @document.root << quota_node(values[:quota]) if values[:quota]
        @document.root << name_node(values[:first_name], values[:last_name]) if values[:first_name] or values[:last_name]

        @document
      end

      # login_node adds an apps:login attribute to @document.
      #  login_node takes a username and password as arguments
      # it is also possible to specify that the account be
      # suspended.
      #
      # login_node suspended, 'username', 'password'
      #
      # login_node returns an 'apps:login' LibXML::XML::Node
      def login_node(suspended = "false", user_name = nil, password = nil)
        login = Atom::XML::Node.new('apps:login')
        login['userName'] = user_name unless user_name.nil?
        login['password'] = OpenSSL::Digest::SHA1.hexdigest password unless password.nil?
        login['hashFunctionName'] = Atom::HASH_FUNCTION unless password.nil?
        suspended.nil? ? login['suspended'] = 'false' : login['suspended'] = suspended

        login
      end


      # quota_node adds an apps:quota attribute to @document.
      # quota_node takes an integer value as an argument.  This
      # argument translates to the number of megabytes available
      # on the Google side.
      #
      # quota_node 1024
      #
      # quota_node returns an 'apps:quota' LibXML::XML::Node
  		def quota_node(limit)
  			quota = Atom::XML::Node.new('apps:quota')
  			quota['limit'] = limit.to_s

  			quota
  		end

      # name_node adds an apps:name attribute to @document.
      # name_node takes the first and last names as arguments.
      #
      # name_node 'first name', 'last name'
      #
      # name_node returns an apps:name LibXML::XML::Node
  		def name_node(first = nil, last = nil)
  			name = Atom::XML::Node.new('apps:name')
  			name['familyName'] = last if last
  			name['givenName'] = first if first

  			name
  		end

      # to_s returns @document as a string
      def to_s
        @document.to_s
      end

      private

      # new_doc re-initializes the XML document.
      def new_doc
        @document = Atom::XML::Document.new
      end

      # TODO: This needs to target the proper nodes.
      # TODO: This needs to treat 'true' and 'false' properly
      def find_values
        map = Atom::MAPS[:user]

        @document.root.each do |entry|
          entry.attributes.each do |attribute|
            instance_variable_set "@#{map[attribute.name.to_sym]}", attribute.value
          end
        end
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
  	end
  end
end