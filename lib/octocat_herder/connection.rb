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

    # If provided a hash of login information, the
    # {OctocatHerder::Connection} will attempt to make authenticated
    # requests.
    #
    # @example Unauthenticated requests
    #   connection = OctocatHerder::Connection.new
    #
    # @example Providing an OAuth2 token
    #   connection = OctocatHerder::Connection.new :oauth2_token => 'token'
    #
    # @example Providing user name & password
    #   connection = OctocatHerder::Connection.new :user_name => 'user', :password => 'pass'
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

    # Execute a GET request against the GitHub v3 API.
    #
    # @since 0.1.0
    #
    # @param [String] end_point The part of the API URL after
    #   +'api.github.com'+, including the leading +'/'+.
    #
    # @param [Hash] options A Hash of options to be passed down to
    #   HTTParty, with a couple of extra options.
    #
    # @option options [true, false] :paginated Retrieve all pages from
    #   a paginated end-point.
    #
    # @option options [Hash<String, Symbol => String>] :params
    #   Constructed into a query string using
    #   {OctocatHerder::Connection#query_string_from_params}.
    def get(end_point, options={})
      paginated = options.delete(:paginated)
      options[:params] ||= {}

      options[:params][:per_page] = 100 if paginated and options[:params][:per_page].nil?

      result = raw_get(end_point, options)
      raise "Unable to retrieve #{end_point}" unless result

      full_result = result.parsed_response

      if paginated
        if next_page = page_from_headers(result.headers, 'next')
          options[:params][:page] = next_page
          options[:paginated]     = true

          full_result += raw_get(end_point, options)
        end
      end

      full_result
    end

    # Small wrapper around HTTParty.get, which handles adding
    # authentication information to the API request.
    #
    # @since 0.1.0
    def raw_get(end_point, options={})
      query_params = options.delete(:params) || {}
      query_string = query_string_from_params(query_params)

      request_options = options.merge(httparty_options)
      if httparty_options.has_key?(:headers) and options.has_key(:headers)
        request_options[:headers] = options[:headers].merge(httparty_options[:headers])
      end

      OctocatHerder::Connection.get(end_point + query_string, request_options)
    end

    # Are we making authenticated requests?
    #
    # @since 0.1.0
    # @return [true, false]
    def authenticated_requests?
      if (user_name and password) or oauth2_token
        true
      else
        false
      end
    end

    # Retrieve the page number of a given 'Link:' header from a hash
    # of HTTP Headers
    #
    # +type+ can be one of:
    # ['+next+'] The immediate next page of results.
    # ['+last+'] The last page of first.
    # ['+first+'] The first page of results.
    # ['+prev+'] The immediate previous page of results.
    #
    # @since 0.1.0
    #
    # @raise [ArgumentError] If type is not one of the allowed values.
    #
    # @param [Hash] headers
    #
    # @param ['next', 'last', 'first', 'prev'] type
    def page_from_headers(headers, type)
      raise ArgumentError.new(
        "Unknown type: #{type}"
      ) unless ['next', 'last', 'first', 'prev'].include? type

      link = LinkHeader.parse(headers['link']).find_link(['rel', type])
      return unless link

      CGI.parse(URI.parse(link.href).query)['page'].first
    end

    # Convenience method to generate URL query strings.
    #
    # @since 0.1.0
    #
    # @param [Hash] params A Hash of key/values to be turned into a
    #   URL query string.  Does not support nested data.
    #
    # @return [String] Empty string if params is an empty hash,
    #   otherwise a string of the query parameters with a leading
    #   +'?'+.
    def query_string_from_params(params)
      return '' if params.keys.empty?

      '?' + params.map {|k,v| "#{URI.escape("#{k}")}=#{URI.escape("#{v}")}"}.join('&')
    end

    private

    def httparty_options
      @httparty_options || {}
    end
  end
end
