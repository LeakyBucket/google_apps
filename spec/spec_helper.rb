require 'google_apps'
require 'yaml'
require 'simplecov'

SimpleCov.start

def get_credentials
  YAML.load_file(cred_file_absolute).inject({}) do |hsh, part|
    hsh[part.flatten[0]] = part.flatten[1]
    hsh
  end
end

def cred_file_absolute
  Dir.getwd + '/spec/credentials.yaml'
end

def to_meth(klasses)
  klasses.inject([]) do |list, klass|
    list << klass.to_s.split('::').last.scan(/[A-Z][a-z0-9]+/).map(&:downcase).join('_')
    list
  end
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

def finished_export
  <<-XML.strip!
    <?xml version='1.0' encoding='UTF-8'?><entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'><id>https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/74876701</id><updated>2012-07-26T13:32:08.438Z</updated><link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/74876701'/><link rel='edit' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/74876701'/><apps:property name='numberOfFiles' value='1'/><apps:property name='packageContent' value='FULL_MESSAGE'/><apps:property name='completedDate' value='2012-07-25 19:13'/><apps:property name='status' value='COMPLETED'/><apps:property name='requestId' value='74876701'/><apps:property name='fileUrl0' value='https://apps-apis.google.com/a/data/compliance/audit/OgAAALqfKGjaeLMsuu54zP7CihO4G2eNZkXAvohVhYW4DjljfG4ltcYzUsjUY95GwfWMoS16ShFAcCr5XdxmC_skWnkAlbTyA8BJje3hRc5lIjExG-BfzzkhShNU'/><apps:property name='userEmailAddress' value='lholcomb2@cnm.edu'/><apps:property name='searchQuery' value='from: *'/><apps:property name='adminEmailAddress' value='lholcomb2@cnm.edu'/><apps:property name='requestDate' value='2012-07-25 15:56'/></entry>
  XML
end

def pending_export
  <<-XML.strip!
    <?xml version='1.0' encoding='UTF-8'?><entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'><id>https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/75133001</id><updated>2012-07-26T13:37:22.497Z</updated><link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/75133001'/><link rel='edit' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/compliance/audit/mail/export/cnm.edu/lholcomb2/75133001'/><apps:property name='packageContent' value='HEADER_ONLY'/><apps:property name='status' value='PENDING'/><apps:property name='requestId' value='75133001'/><apps:property name='userEmailAddress' value='lholcomb2@cnm.edu'/><apps:property name='searchQuery' value='from: *'/><apps:property name='adminEmailAddress' value='lholcomb2@cnm.edu'/><apps:property name='requestDate' value='2012-07-26 13:37'/></entry>
  XML
end

def fake_nickname
  <<-XML.strip!
    <?xml version="1.0" encoding="UTF-8"?><atom:entry xmlns:atom="http://www.w3.org/2005/Atom" xmlns:apps="http://schemas.google.com/apps/2006">  <apps:category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/apps/2006#nickname"/>  <apps:nickname name="bobo"/></atom:entry>
  XML
end