module GoogleApps
	module Atom
  	class User < Document
      attr_reader :doc, :login, :suspended, :first_name, :last_name, :quota, :password

      MAP = {
        userName: :login,
        suspended: :suspended,
        familyName: :last_name,
        givenName: :first_name,
        limit: :quota,
        password: :password
      }

  		def initialize(xml = nil)
        if xml
          super(xml, MAP)
          find_values
        else
          super(nil, MAP)
  			  @doc.root = build_root :user
        end
  		end


      # set adds the values for the given attributes to the
      # current document.  populates takes a hash of attribute,
      # value pairs.
      #
      # set login: 'Zuddile', password: 'old shoes'
      def set(attributes)
        attributes.keys.each do |key|
          self.send("#{key}=", attributes[key])
        end
      end


      # add_node creates the specified node in the user document.  It
      # takes a type/name and an array of attribute, value pairs as
      # arguments.  It also parses the new document and saves the
      # copy in @doc
      #
      # add_node 'apps:login', [['userName', 'Zanzabar']]
      #
      # add_node returns a parsed copy of the new document.
      def add_node(type, attrs) # TODO: Should take a target argument rather than only appending to @doc.root
        @doc.root << create_node(type: type, attrs: attrs)

        @doc = parse @doc
      end


      # update_node updates an existing node in the document.  It takes
      # the type/name, attribute name and the new value as arguments
      #
      # update_node 'apps:login', :userName, true
      def update_node(type, attribute, value)
        find_and_update "//#{type}", { attribute => [instance_variable_get("@#{MAP[attribute]}").to_s, value.to_s]}
      end


      # TODO: Move this method.
      def node(name)
        @doc.find_first("//#{name}")
      end


      # NOTE: setters should work even if target node exists but has no suspended property.  Unless libxml-ruby changes it's default for the attributes hash on a node.


      # suspended= sets the suspended value for the account
      #
      # suspended = true
      #
      # suspended= returns the value that has been set
      def suspended=(value)
        node('apps:login') ? update_node('apps:login', :suspended, value) : add_node('apps:login', [['suspended', value.to_s]])

        @suspended = value
      end


      # login= sets the login/account name for this entry
      #
      # login = 'Zanzabar'
      #
      # login= returns the value that has been set
      def login=(login)
        node('apps:login') ? update_node('apps:login', :userName, login) : add_node('apps:login', [['userName', login]])

        @login = login
      end


      # first_name= sets the first name for this user entry
      #
      # first_name = 'Lou'
      #
      # first_name returns the value that has been set
      def first_name=(name)
        node('apps:name') ? update_node('apps:name', :givenName, name) : add_node('apps:name', [['givenName', name]])

        @first_name = name
      end


      # last_name= sets the last name for this user entry
      #
      # last_name = 'Svensen'
      #
      # last_name= returns the value that has been set
      def last_name=(name)
        node('apps:name') ? update_node('apps:name', :familyName, name) : add_node('apps:name', [['familyName', name]])

        @last_name = name
      end


      # quota= sets the quota for this user entry
      #
      # quota = 123456
      #
      # quota= returns the value that has been set
      def quota=(limit)
        node('apps:quota') ? update_node('apps:quota', :limit, limit) : add_node('apps:quota', [['limit', limit.to_s]])

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

        node('apps:login') ? update_node('apps:login', :password, hashed) : add_node('apps:login', [['password', hashed]])

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


      # to_s returns @doc as a string
      def to_s
        @doc.to_s
      end


      private

      # new_doc re-initializes the XML document.
      def new_doc
        @doc = Atom::XML::Document.new
      end
  	end
  end
end