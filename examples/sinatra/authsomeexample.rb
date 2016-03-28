require 'erb'
require 'authsome'

class AuthsomeExample < Sinatra::Base

enable :sessions

  def initialize(*args)
    super

    # ~~~~~ Redis set up ~~~~~ #
    local = !(File.exists? '/home/dotcloud/environment.json')

    file = '/home/dotcloud/environment.json'
    file = 'environment_dev.json' if local

    @authsome = Authsome.new(file);

  end

  def loggedin?()
    if (@user_id == nil) then
      redirect '/login'
    else
      return true
    end
  end

  get '/login' do
    if (params[:user]) then
      if ( params[:user].eql?("1") or params[:user].eql?("2") ) then
        #session[:user_id] = params[:user]
        @@expiration_date = Time.now + (60 * 2)
        response.set_cookie("user_id", :value => params[:user],:expires => @@expiration_date)
        redirect '/'
      else
        redirect '/login'
      end
    else
      str = erb :login
      [200, str]
    end
  end

  get '/logout' do
    @authsome.close_services
    response.delete_cookie("user_id")
    redirect '/'
  end

  before do
    @user_id = request.cookies["user_id"]
    @authsome.open_services(@user_id) if (@user_id != nil)
  end

  after do
    @authsome.close_services
  end

  # Dashboard fake example
  get '/' do
    loggedin?
    @title = "access your apps with authsome!"
    @authed           = {}

    @authsome.get_services.each do |plugin, service|
      @authed[plugin] = service.authorized?
    end

    str = erb :dashboard
    [200, str]
  end

  # Service authorization
  get '/:service/auth' do
    loggedin?
    redirect @authsome.get_services[params[:service]].auth(request)
  end

  get '/:service/auth/callback' do
    loggedin?
    @authsome.get_services[params[:service]].callback(params, @user_id)
    redirect '/'
  end

  get '/:service/deauth' do
    loggedin?
    @authsome.get_services[params[:service]].deauth(@user_id)
    redirect '/'
  end

  # Service tests
  get '/:service/test' do
    loggedin?
    str = @authsome.get_services[params[:service]].test
    [200, str]
  end

end