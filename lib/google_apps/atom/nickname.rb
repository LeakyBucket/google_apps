module GoogleApps
  module Atom
    class Nickname
      include GoogleApps::Atom::Node
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
        @nickname.nil? ? set_nickname(nick) : change_nickname(nick)
      end


      # user= sets the username value on the object and in the
      # underlying XML document.  It takes a string (email address)
      # as an argument.
      #
      # user = 'tom@work.com'
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


      # header returns an atom:entry node with the appropriate
      # namespaces for a GoogleApps nickname document
      def header
        node = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(node, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(node, 'apps', 'http://schemas.google.com/apps/2006')

        node
      end


      # category constructs an atom:category node with the
      # appropriate attributes for a GoogleApps nickname
      # document.
      def category
        node = Atom::XML::Node.new('atom:category')
        node.attributes['scheme'] = 'http://schemas.google.com/g/2005#kind'
        node.attributes['term'] = 'http://schemas.google.com/apps/2006#nickname'

        node
      end


      # set_nickname adds an apps:nickname node to the
      # underlying XML document and sets @nickname.
      # It takes a nickname in string form for its
      # argument.
      #
      # set_nickname 'Timmy'
      #
      # set_nickname returns the new nickname value.
      def set_nickname(nick)
        @document.root << create_node(type: 'apps:nickname', attrs: [['name', nick]])

        @nickname = nick
      end


      # set_user adds an apps:login node to the underlying
      # XML document and sets @user.  It takes a username
      # (email address) in string form for its argument.
      #
      # set_user 'bob@work.com'
      #
      # set_user returns the new user value.
      def set_user(username)
        @document.root << create_node(type: 'apps:login', attrs: [['userName', username]])

        @user = username
      end


      # change_nickname changes the name attribute for the
      # apps:nickname node in the underlying XML document.
      # It takes a nickname in string form.
      #
      # change_nickname 'Timmy'
      #
      # change_nickname returns the new nickname.
      def change_nickname(nick)
        @document.root.each do |node|
          node.attributes['name'] = nick if node.attributes['name'] == @nickname
        end

        @nickname = nick
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