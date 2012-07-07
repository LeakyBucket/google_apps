module GoogleApps
	module Atom
    # TODO: Move User attribute map to user class
    # TODO: Update attribute map to include @ for instance variables
  	class User
      include Atom::Node
      include Atom::Document

      attr_reader :document, :login, :suspended, :first_name, :last_name, :quota, :password

  		def initialize(xml = nil)
        if xml
          @document = parse(xml)
          find_values
        else
          @document = new_empty_doc
  			  add_header
        end
  		end


      # populate adds the values for the given attributes to the
      # current document.  populates takes a hash of attribute,
      # value pairs.
      #
      # populate login: 'Zuddile', password: 'old shoes'
      def populate(attributes)
        attributes.keys.each do |key|
          self.send("#{key}=", attributes[key])
        end
      end


      # TODO: Document
      def set_values(values = {})
        # Don't want to create login_node if nothing has been specified.
        @document.root << login_node(values[:suspended], values[:username], values[:password])
        @document.root << quota_node(values[:quota]) if values[:quota]
        @document.root << name_node(values[:first_name], values[:last_name]) if values[:first_name] or values[:last_name]

        @document
      end


      # set creates the specified node in the user document.  It
      # takes a type/name and an array of attribute, value pairs as
      # arguments.  It also parses the new document and saves the
      # copy in @document
      #
      # set 'apps:login', [['userName', 'Zanzabar']]
      #
      # set returns a parsed copy of the new document.
      def set(type, attrs) # TODO: Should take a target argument rather than only appending to @document.root
        @document.root << create_node(type: type, attrs: attrs)

        @document = parse @document
      end


      # update updates an existing node in the document.  It takes
      # the type/name, attribute name and the new value as arguments
      #
      # update 'apps:login', :userName, true
      def update(type, attribute, value)
        find_and_update @document, "//#{type}", { attribute => [instance_variable_get("@#{Atom::MAPS[:user][attribute]}").to_s, value.to_s]}
      end


      # TODO: Move this method.
      def node(name)
        @document.find_first("//#{name}")
      end


      # NOTE: This should work even if apps:login exists but has no suspended property.  Unless libxml-ruby changes it's default for the attributes hash on a node.
      def suspended=(value)
        node('apps:login') ? update('apps:login', :suspended, value) : set('apps:login', [['suspended', value.to_s]])

        @suspended = value
      end


      # login= sets the login/account name for this entry
      #
      # login = 'Zanzabar'
      #
      # login= returns the value that has been set
      def login=(login)
        node('apps:login') ? update('apps:login', :userName, login) : set('apps:login', [['userName', login]])

        @login = login
      end


      # first_name= sets the first name for this user entry
      #
      # first_name = 'Lou'
      #
      # first_name returns the value that has been set
      def first_name=(name)
        node('apps:name') ? update('apps:name', :givenName, name) : set('apps:name', [['givenName', name]])

        @first_name = name
      end


      # last_name= sets the last name for this user entry
      #
      # last_name = 'Svensen'
      #
      # last_name= returns the value that has been set
      def last_name=(name)
        node('apps:name') ? update('apps:name', :familyName, name) : set('apps:name', [['familyName', name]])

        @last_name = name
      end


      # quota= sets the quota for this user entry
      #
      # quota = 123456
      #
      # quota= returns the value that has been set
      def quota=(limit)
        node('apps:quota') ? update('apps:quota', :limit, limit) : set('apps:quota', [['limit', limit.to_s]])

        @quota = limit
      end


      # password= sets the password and hashFunctionName attributes
      # in the apps:login node.  It takes a plaintext string as it's
      # only argument.
      #
      # password = 'new password'
      #
      # password= returns the value that has been set
      def password=(password)
        hashed = hash_password(password)

        node('apps:login') ? update('apps:login', :password, hashed) : set('apps:login', [['password', hashed]])

        add_attributes node('apps:login'), [['hashFunctionName', Atom::HASH_FUNCTION]]

        @password = hashed
      end


      # hash_password hashes the provided password
      #
      # hash_password 'new password'
      #
      # hash_password returns an SHA1 digest of the password
      def hash_password(password)
        OpenSSL::Digest::SHA1.hexdigest password
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
        create_node type: 'apps:quota', attrs: [['limit', limit.to_s]]
  		end


      # name_node adds an apps:name attribute to @document.
      # name_node takes the first and last names as arguments.
      #
      # name_node 'first name', 'last name'
      #
      # name_node returns an apps:name LibXML::XML::Node
  		def name_node(first = nil, last = nil)
        attrs = []
        attrs << ['givenName', first] if first
        attrs << ['familyName', last] if last

        create_node(type: 'apps:name', attrs: attrs) unless attrs.empty?
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
            instance_variable_set "@#{map[attribute.name.to_sym]}", check_value(attribute.value)
          end
        end
      end


      def check_value(value)
        case value
          when 'true'
            true
          when 'false'
            false
          else
            value
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