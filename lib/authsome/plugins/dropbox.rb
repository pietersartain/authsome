require 'dropbox_sdk'
require 'authsome/service'

require 'pp'

class AuthsomeDropbox < AuthsomeService
  ACCESS_TYPE = :app_folder

  def initialize(keys, data)
    @service  = "dropbox"
    @data     = data
    @key      = keys["#{@service.upcase}_KEY"]
    @secret   = keys["#{@service.upcase}_SECRET"]
  end

  def auth(request)
    @session  = DropboxSession.new(@key, @secret)
    @session.get_request_token
    return @session.get_authorize_url("http://#{request.host}:#{request.port}/#{@service}/auth/callback")
  end

  def callback(params, user)
    if !authorized?
      token = @session.get_access_token
      @client   = DropboxClient.new(@session, ACCESS_TYPE)
      @atoken = @session.serialize
      @data.hmset(@service,"atoken_"<<user,@atoken)
      return true
    end
    return nil
  end

  def open(user)
    @atoken   = @data.hget(@service,"atoken_"<<user)
    if authorized? then
      @session  = DropboxSession.deserialize(@atoken)
      @client   = DropboxClient.new(@session, ACCESS_TYPE)
    end
  end

  def test()
    @client.account_info.inspect
  end

  def filelist()
    #if @data.get("")
    pp @client.metadata('.',25000,true,metahash)
  end

end