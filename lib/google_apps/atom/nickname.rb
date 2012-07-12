module GoogleApps
  module Atom
    class Nickname
      include Atom::Node
      include Atom::Document

      attr_reader :nickname, :user, :document

      ELEMENTS = { nick: ['apps:nickname', 'name'], user: ['apps:login', 'userName'] }

      def initialize
        @document = Atom::XML::Document.new
        @document.root = header
        @document.root << category
      end

      # nickname= sets the nickname value on the object and in the
      # underlying XML document.  It takes a string as an argument.
      #
      # nickname = 'Timmy'
      #
      # nickname= returns the new nickname value
      def nickname=(nick)
        @nickname ? find_and_update(@document, '//apps:nickname', name: [@nickname, nick]) : create('nickname', nick)

        @nickname = nick
      end


      # user= sets the username value on the object and in the
      # underlying XML document.  It takes a string (default/current username)
      # as an argument.
      #
      # user = 'tom'
      #
      # user= returns the new username value
      def user=(username)
        @user.nil? ? set_user(username) : change_user(username)
      end


      # to_s returns the underlying XML document as a string.
      def to_s
        @document.to_s
      end



      private


      def create(type, value)
        case type
        when 'nickname'
          @document.root << create_node(type: 'apps:nickname', attrs: [['name', value]])
        when 'login'
          @document.root << create_node(type: 'apps:login', attrs: [['userName', value]])
        end

        @document = parse @document
      end


      # header returns an atom:entry node with the appropriate
      # namespaces for a GoogleApps nickname document
      def header
        add_namespaces create_node(type: 'atom:entry'), atom: 'http://www.w3.org/2005/Atom', apps: 'http://schemas.google.com/apps/2006'
      end


      # category constructs an atom:category node with the
      # appropriate attributes for a GoogleApps nickname
      # document.
      def category
        create_node type: 'atom:category', attrs: Atom::CATEGORY[:nickname]
      end


      # set_user adds an apps:login node to the underlying
      # XML document and sets @user.  It takes a username
      # (current/default username) in string form for its
      # argument.
      #
      # set_user 'bob'
      #
      # set_user returns the new user value.
      def set_user(username)
        @document.root << create_node(type: 'apps:login', attrs: [['userName', username]])

        @user = username
      end


      # change_user changes the userName attribute for the
      # apps:login node in the underlying XML document. It
      # takes a username (Email format) in string form.
      #
      # change_user 'bob@work.com'
      #
      # change_user returns the new user value.
      def change_user(username)
        @document.root.each do |node|
          node.attributes['userName'] = username if node.attributes['userName'] == @user
        end

        @user = username
      end

      # :nodoc:
      def change_element(type, value)
        @document.root.each do |node|
          node.attributes[ELEMENTS[type][1]] = value
        end
      end


      # parse_document takes an XML document and returns
      # a parsed copy of that document.
      def parse_document(document = @document)
        Atom::XML::Parser.document(document).parse
      end
    end
  end
end