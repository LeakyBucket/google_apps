class Klient
  include GoogleApps::Client

  def initialize(domain)
    @domain = domain
  end

  def make_request(method, url, options = {})
    if [:get, :delete].include?(method)
      RestClient.send(method, url, options[:headers])
    else
      RestClient.send(method, url, options[:body], options[:headers])
    end
  end
end