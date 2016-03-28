require 'instagram'
require 'authsome/service'

class AuthsomeInstagram < AuthsomeService

  def initialize(keys, data)
    @service  = "instagram"

    Instagram.configure do |config|
      config.client_id     = keys["#{@service.upcase}_KEY"]
      config.client_secret = keys["#{@service.upcase}_SECRET"]
    end

    @data     = data
    @callback = ''
  end

  def auth(request)
    @callback = "http://#{request.host}:#{request.port}/#{@service}/auth/callback"
    return Instagram.authorize_url(:redirect_uri => @callback)
  end

  def callback(params, user)
    if !authorized?
      response = Instagram.get_access_token(params[:code], :redirect_uri => @callback)
     @atoken = response.access_token
     @data.hset(@service,"atoken_"<<user,@atoken)
     return true
   else
     return nil
   end
  end

  def open(user)
    @atoken   = @data.hget(@service,"atoken_"<<user)
    @client   = Instagram.client(:access_token => @atoken) if authorized? 
  end

  def test
    user = @client.user

    html = "<h1>#{user.username}'s recent photos</h1>"
    for media_item in @client.user_recent_media
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end

    return html
  end

end