class GoogleApps
  class ClientLogin
    include GoogleApps::Client

    def initialize(options = {})
      @domain = options[:domain]
    end

    def make_request(method, url, options = {})
      headers = {'authorization' => "GoogleLogin auth=#{@token}"}.merge(options.delete(:headers) || {})
      if [:get, :delete].include?(method)
        RestClient.send(method, url, headers)
      else
        RestClient.send(method, url, options[:body], headers)
      end
    end

    def authenticate!(email, password)
      url = "https://www.google.com/accounts/ClientLogin"
      headers = {'content-type' => 'application/x-www-form-urlencoded'}
      auth_body = "&Email=#{CGI::escape(email)}&Passwd=#{CGI::escape(password)}&accountType=HOSTED&service=apps"
      response = RestClient.post(url, auth_body, headers)

      response.body.split("\n").grep(/auth=(.*)/i)
      @token = $1
    end
  end
end