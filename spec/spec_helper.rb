require 'google_apps'
require 'yaml'

def get_credentials
  YAML.load_file(cred_file_absolute).inject({}) do |hsh, part|
    hsh[part.flatten[0]] = part.flatten[1]
    hsh
  end
end

def cred_file_absolute
  Dir.getwd + '/spec/credentials.yaml'
end

def basic_header
  '<atom:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:apps="http://schemas.google.com/apps/2006" xmlns:gd="http://schemas.google.com/g/2005"/>'
end

def generate_username
  characters = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten

  (0..6).map { characters[rand(characters.length)] }.join
end

def get_path(category)
  transporter.send(category.to_sym).split('/')[3..-1].join('/')
end

def build_request(verb)
  GoogleApps::AppsRequest.new verb, 'http://www.google.com', test: 'bob'
end

def entry_node
  entry = LibXML::XML::Node.new 'entry'

  entry << LibXML::XML::Node.new('uncle')
  entry << LibXML::XML::Node.new('aunt')

  entry
end

def hash_password(password)
  OpenSSL::Digest::SHA1.hexdigest password
end