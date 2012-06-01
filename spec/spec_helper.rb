require 'google_apps'
require 'yaml'

def get_credentials
  YAML.load_file(cred_file_absolute)
end

def cred_file_absolute
  Dir.getwd + '/spec/credentials.yaml' 
end

def generate_username
  characters = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten

  (0..6).map { characters[rand(characters.length)] }.join
end