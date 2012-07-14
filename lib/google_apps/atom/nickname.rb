module GoogleApps
  module Atom
    class Nickname
      include Atom::Node
      include Atom::Document

      attr_reader :nickname, :user, :document

      ELEMENTS = { nick: ['apps:nickname', 'name'], user: ['apps:login', 'userName'] }

      def initialize
        @document = Atom::XML::Document.new
        @document.root = build_root
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
        @user ? find_and_update(@document, '//apps:login', userName: [@user, username]) : create('login', username)

        @user = username
      end


      # to_s returns the underlying XML document as a string.
      def to_s
        @document.to_s
      end



      private


      # create adds the specified node to @document.  It takes
      # a type and a value as arguments.
      #
      # create 'nickname', 'Bob'
      #
      # create returns a parsed copy of the document.
      def create(type, value)
        case type
        when 'nickname'
          @document.root << create_node(type: 'apps:nickname', attrs: [['name', value]])
        when 'login'
          @document.root << create_node(type: 'apps:login', attrs: [['userName', value]])
        end

        @document = parse @document
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