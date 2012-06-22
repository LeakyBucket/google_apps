module GoogleApps
  module Atom
    class Nickname
      attr_reader :nickname, :user, :document

      ELEMENTS = { nick: ['apps:nickname', 'name'], user: ['apps:login', 'userName'] }

      def initialize
        @document = Atom::XML::Document.new
        @document.root = header
        @document.root << category
      end

      def nickname=(nick)
        @nickname.nil? ? set_nickname(nick) : change_nickname(nick)
      end

      def user=(username)
        @user.nil? ? set_user(username) : change_user(username)
      end

      def to_s
        @document.to_s
      end



      private

      def header
        node = Atom::XML::Node.new('atom:entry')

        Atom::XML::Namespace.new(node, 'atom', 'http://www.w3.org/2005/Atom')
        Atom::XML::Namespace.new(node, 'apps', 'http://schemas.google.com/apps/2006')

        node
      end


      def category
        node = Atom::XML::Node.new('atom:category')
        node.attributes['scheme'] = 'http://schemas.google.com/g/2005#kind'
        node.attributes['term'] = 'http://schemas.google.com/apps/2006#nickname'

        node
      end


      def set_nickname(nick)
        @document.root << new_element(:nick, nick)

        @nickname = nick
      end


      def set_user(username)
        @document.root << new_element(:user, username)

        @user = username
      end


      def change_nickname(nick)
        @document.root.each do |node|
          node.attributes['name'] = nick if node.attributes['name'] == @nickname
        end

        @nickname = nick
      end


      def change_user(username)
        @document.root.each do |node|
          node.attributes['userName'] = username if node.attributes['userName'] == @user
        end

        @user = username
      end


      def new_element(type, value)
        node = Atom::XML::Node.new ELEMENTS[type][0]
        node.attributes[ELEMENTS[type][1]] = value

        node
      end


      def parse_document(document = @document)
        Atom::XML::Parser.document(document).parse
      end
    end
  end
end