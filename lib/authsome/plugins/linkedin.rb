require 'linkedin'
require 'authsome/service'

class AuthsomeLinkedin < AuthsomeService

  def initialize(keys, data)
    @service  = "linkedin"
    @data     = data
    @key      = keys["#{@service.upcase}_KEY"]
    @secret   = keys["#{@service.upcase}_SECRET"]
    @client   = LinkedIn::Client.new(@key, @secret)
  end

  def auth(request)
    request_token = @client.request_token(:oauth_callback => "http://#{request.host}:#{request.port}/#{@service}/auth/callback")
    @rtoken  = request_token.token
    @rsecret = request_token.secret
    return @client.request_token.authorize_url
  end

  def callback(params, user)
    if !authorized?
      pin = params[:oauth_verifier]
      @atoken, @asecret = @client.authorize_from_request(@rtoken, @rsecret, pin)
      @data.hmset(@service,"atoken_"<<user,@atoken,"asecret_"<<user,@asecret)
      return true
    end
    return nil
  end

  def open(user)
    @atoken   = @data.hget(@service,"atoken_"<<user)
    @asecret  = @data.hget(@service,"asecret_"<<user)
    @client.authorize_from_access(@atoken, @asecret) if authorized?
  end

  def test
    return @client.profile(:fields => %w(first-name last-name headline location specialties educations positions picture-url summary)).to_s
  end

end