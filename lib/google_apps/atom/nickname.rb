module GoogleApps
  module Atom
    class Nickname < Document
      attr_reader :nickname, :user, :doc

      ELEMENTS = { nick: ['apps:nickname', 'name'], user: ['apps:login', 'userName'] }

      def initialize(xml = nil)
        super(xml)
        @doc.root = build_root(:nickname) unless xml
      end

      # nickname= sets the nickname value on the object and in the
      # underlying XML document.  It takes a string as an argument.
      #
      # nickname = 'Timmy'
      #
      # nickname= returns the new nickname value
      def nickname=(nick)
        @nickname ? find_and_update('//apps:nickname', name: [@nickname, nick]) : create('nickname', nick)

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
        @user ? find_and_update('//apps:login', userName: [@user, username]) : create('login', username)

        @user = username
      end


      # to_s returns the underlying XML document as a string.
      def to_s
        @doc.to_s
      end



      private


      # create adds the specified node to @doc.  It takes
      # a type and a value as arguments.
      #
      # create 'nickname', 'Bob'
      #
      # create returns a parsed copy of the document.
      def create(type, value)
        case type
        when 'nickname'
          @doc.root << create_node(type: 'apps:nickname', attrs: [['name', value]])
        when 'login'
          @doc.root << create_node(type: 'apps:login', attrs: [['userName', value]])
        end

        @doc = parse @doc
      end
    end
  end
end