require 'httparty'
require 'link_header'

class OctocatHerder
  # This implements some additional functionality around HTTParty to
  # help make working with the GitHub API a little nicer.
  class Connection
    include HTTParty
    base_uri 'https://api.github.com'

    # User name to use when doing basic HTTP authentication.
    #
    # @since 0.0.1
    attr_reader :user_name

    # Password to use when doing basic HTTP authentication.
    #
    # @since 0.0.1
    attr_reader :password

    # The OAuth2 token to use when doing OAuth2 authentication.
    #
    # @since 0.0.1
    attr_reader :oauth2_token

    # If provided a hash of login information, the Connection will attempt to make authenticated requests.
    #
    # Login information can be provided as
    #   :user_name => 'user', :password => 'pass'
    # or
    #   :oauth2_token => 'token'
    #
    # If no hash is provided, then unauthenticated requests will be
    # made.
    #
    # @since 0.0.1
    # @param [Hash<Symbol => String>] options Login information
    # @option options [String] :user_name
    # @option options [String] :password
    # @option options [String] :oauth2_token
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

    # Small wrapper around the standard HTTParty +get+ method, which
    # handles adding authentication information to the API request.
    #
    # @since 0.0.1
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
