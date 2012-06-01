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

def generate_username
  characters = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten

  (0..6).map { characters[rand(characters.length)] }.join
end