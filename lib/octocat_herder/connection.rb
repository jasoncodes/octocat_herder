require 'httparty'
require 'link_header'

class OctocatHerder
  class Connection
    include HTTParty
    base_uri 'https://api.github.com'

    attr_reader :user_name, :password, :oauth2_token

    def initialize(options={})
      raise ArgumentError.new(
        "OctocatHerder::Connection does not accept: #{options.class}"
      ) unless options.is_a? Hash

      options.keys.each do |k|
        raise ArgumentError.new("Unknown option: '#{k}'") unless [
          :user_name, :password, :oauth2_token
        ].include? k
      end

      if options.keys.include?(:user_name) or options.keys.include?(:password)
        raise ArgumentError.new("When providing :user_name or :password, both are required") unless
          options.keys.include?(:user_name) and options.keys.include?(:password)
      end

      if options.keys.include?(:oauth2_token) and options.keys.include?(:user_name)
        raise ArgumentError.new('Cannot provide both an OAuth2 token, and a user name and password')
      end

      @user_name    = options[:user_name]
      @password     = options[:password]
      @oauth2_token = options[:oauth2_token]

      if oauth2_token
        @httparty_options = { :headers => { 'Authorization' => "token #{oauth2_token}" } }
      elsif user_name
        @httparty_options = { :basic_auth => { :username => user_name, :password => password } }
      end
    end

    def get(end_point, options={})
      request_options = options.merge(httparty_options)
      if httparty_options.has_key?(:headers) and options.has_key(:headers)
        request_options[:headers] = options[:headers].merge(httparty_options[:headers])
      end

      OctocatHerder::Connection.get(end_point, request_options)
    end

    private

    def httparty_options
      @httparty_options || {}
    end
  end
end
