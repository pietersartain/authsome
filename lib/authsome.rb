require 'redis'
require 'json'

class Authsome

  def initialize(file)    
    @env = JSON.parse(File.read(file))

    @data = Redis.new(:host => @env['DOTCLOUD_DATA_REDIS_HOST'], 
                      :port => @env['DOTCLOUD_DATA_REDIS_PORT'])

    auth = @env.has_key? 'DOTCLOUD_DATA_REDIS_PASSWORD'

    @data.auth(@env['DOTCLOUD_DATA_REDIS_PASSWORD']) if auth

    @authsome_service = {}
    dirname = File.dirname(__FILE__) << "/authsome/plugins/"

    Dir.glob(dirname << "*") do |file|
      plugin   = file.match(/#{dirname}(.*)\.rb/)[1]
      require 'authsome/plugins/' << plugin
      instance = 'Authsome' << plugin.capitalize
      @authsome_service[plugin] = eval(instance + '.new(@env, @data)')
    end
  end

  def get_services
    return @authsome_service
  end

  def open_services(user)
    @authsome_service.each {|plugin, service| service.open(user)}
  end

  def close_services
    @authsome_service.each {|plugin, service| service.close}
  end


end