require 'cgi'

require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/user'
require 'octocat_herder/pull_request/repo'

class OctocatHerder
  # Interface to the GitHub v3 API for interacting with pull requests.
  #
  # Currently, this only supports retrieval of information about the
  # pull request itself, not the comments, or any updating/creation.
  class PullRequest
    include OctocatHerder::Base

    # Returns a list of OctocatHerder::PullRequest instances
    # representing the pull requests for a given repository.
    #
    # [owner_login] The login name of the repository owner.
    # [repository_name] The name of the repository itself.
    # [status] One of 'open' or 'closed'.  Defaults to querying open pull requests.
    # [conn] The optional OctocatHerder::Connection to use for API requests.  Defaults to unauthenticated requests.
    def self.find_for_repository(owner_login, repository_name, status = 'open', conn = OctocatHerder::Connection.new)
      raise ArgumentError.new("Unknown PullRequest status '#{status}'.  Must be one of ['open', 'closed'].") unless
        ['open', 'closed'].include? status

      pull_requests = raw_get(
        conn,
        "/repos/#{CGI.escape(owner_login.to_s)}/#{CGI.escape(repository_name.to_s)}/pulls",
        :paginated => true,
        :params    => { :state => status },
        :headers   => { 'Accept' => 'application/vnd.github-pull.full+json' }
      )

      pull_requests.map do |pull|
        new(pull, nil, conn)
      end
    end

    # Returns a list of OctocatHerder::PullRequest instances
    # representing the open pull requests for a given repository.
    #
    # [owner_login] The login name of the repository owner.
    # [repository_name] The name of the repository itself.
    # [conn] The optional OctocatHerder::Connection to use for API requests.  Defaults to unauthenticated requests.
    def self.find_open_for_repository(owner_login, repository_name, conn = OctocatHerder::Connection.new)
      OctocatHerder::PullRequest.find_for_repository(owner_login, repository_name, 'open', conn)
    end

    # Returns a list of OctocatHerder::PullRequest instances
    # representing the closed pull requests for a given repository.
    #
    # [owner_login] The login name of the repository owner.
    # [repository_name] The name of the repository itself.
    # [conn] The optional OctocatHerder::Connection to use for API requests.  Defaults to unauthenticated requests.
    def self.find_closed_for_repository(owner_login, repository_name, conn = OctocatHerder::Connection.new)
      OctocatHerder::PullRequest.find_for_repository(owner_login, repository_name, 'closed', conn)
    end

    # Returns a single OctocatHerder::PullRequest instance
    # representing the given pull request.
    #
    # [owner_login] The login name of the repository owner.
    # [repository_name] The name of the repository itself.
    # [pull_request_number] The pull request to retrieve.
    # [conn] The optional OctocatHerder::Connection to use for API requests.  Defaults to unauthenticated requests.
    def self.fetch(owner_login, repository_name, pull_request_number, conn = OctocatHerder::Connection.new)
      request = raw_get(
        conn,
        "/repos/#{CGI.escape(owner_login.to_s)}/#{CGI.escape(repository_name.to_s)}/pulls/#{CGI.escape(pull_request_number.to_s)}",
        :headers   => { 'Accept' => 'application/vnd.github-pull.full+json' }
      )

      new(nil, request, conn)
    end

    # Not intended for public consumption.
    #
    # [raw_hash] The 'overview' information retrieved from the pull request listing API.
    # [raw_detail_hash] The full information available by querying information about a specific pull request.
    # [conn] The OctocatHerder::Connection instance to use for querying the API.  Defaults to unauthenticated requests.
    def initialize(raw_hash, raw_detail_hash = nil, conn = OctocatHerder::Connection.new)
      super raw_hash, conn
      @raw_detail_hash = raw_detail_hash
    end

    # Get the full pull request details.  When retrieved from
    # .find_for_repository, .find_open_for_repository, or
    # .find_closed_for_repository not all of the details of the pull
    # request are available since GitHub doesn't return them in the
    # listing.  This will query information about the specific pull
    # request, which will get us all of the available details.
    def get_detail
      return if @raw_detail_hash

      @raw_detail_hash = raw_get(
        url,
        :headers => { 'Accept' => 'application/vnd.github-pull.full+json' }
      )

      self
    end

    # Check the "normal" place first for the information returned by
    # the GitHub API, then check +@raw_detail_hash+ (populating it if
    # needed).
    def method_missing(id, *args)
      super
    rescue NoMethodError => e
      get_detail
      return @raw_detail_hash[id.id2name] if @raw_detail_hash and @raw_detail_hash.keys.include?(id.id2name)

      raise e
    end

    # The URL to the avatar image of the person that opened the pull request.
    #
    # Since this is returned by the pull request API itself, this can
    # be used without making an additional API request.
    def user_avatar_url
      return @raw['user']['avatar_url'] if @raw
      @raw_detail_hash['user']['avatar_url']
    end

    # The URL of the person that opened the pull request.
    #
    # Since this is returned by the pull request API itself, this can
    # be used without making an additional API request.
    def user_url
      return @raw['user']['url'] if @raw
      @raw_detail_hash['user']['url']
    end

    # The ID number of the person that opened the pull request.
    #
    # Since this is returned by the pull request API itself, this can
    # be used without making an additional API request.
    def user_id
      return @raw['user']['id'] if @raw
      @raw_detail_hash['user']['id']
    end

    # The login name of the person that opened the pull request.
    #
    # Since this is returned by the pull request API itself, this can
    # be used without making an additional API request.
    def user_login
      return @raw['user']['login'] if @raw
      @raw_detail_hash['user']['login']
    end

    # Return an OctocatHerder::User representing the user that opened
    # the pull request.
    #
    # This is cached locally to the individual pull request, but will
    # make an additional API request to populate it initially.
    def user
      @user ||= OctocatHerder::User.fetch(user_login, connection)
    end

    # The login name of the person that merged the pull request, or
    # +nil+ if it has not been merged yet.
    def merged_by_login
      return nil unless merged

      get_detail
      @raw_detail_hash['merged_by']['login']
    end

    # The ID number of the person that merged the pull request, or
    # +nil+ if it has not been merged yet.
    def merged_by_id
      return nil unless merged

      get_detail
      @raw_detail_hash['merged_by']['id']
    end

    # The URL to the avatar image of the person that merged the pull
    # request, or +nil+ if it has not been merged yet.
    def merged_by_avatar_url
      return nil unless merged

      get_detail
      @raw_detail_hash['merged_by']['avatar_url']
    end

    # The URL of the person that merged the pull request, or +nil+ if
    # it has not been merged yet.
    def merged_by_url
      return nil unless merged

      get_detail
      @raw_detail_hash['merged_by']['url']
    end

    # Return an OctocatHerder::User representing the user that merged
    # the pull request, or +nil+ if it has not been merged yet.
    #
    # This is cached locally to the individual pull request, but will
    # make an additional API request to populate it initially.
    def merged_by
      return nil unless merged

      @merged_by ||= OctocatHerder::User.fetch(merged_by_login, connection)
    end

    # When the pull request was first created as a Ruby Time object.
    def created_at
      parse_date_time(@raw_detail_hash['created_at'])
    end

    # When the pull request was last updated as a Ruby Time object.
    def updated_at
      parse_date_time(@raw_detail_hash['updated_at'])
    end

    # When the pull request was closed as a Ruby Time object.
    def closed_at
      parse_date_time(@raw_detail_hash['closed_at'])
    end

    # When the pull request was merged as a Ruby Time object.
    def merged_at
      parse_date_time(@raw_detail_hash['merged_at'])
    end

    # Returns an OctocatHerder::PullRequest::Repo representing
    # information about what is being asked to be merged in the pull
    # request.
    def head
      get_detail

      @head_repo ||= OctocatHerder::PullRequest::Repo.new(@raw_detail_hash['head'], connection)
    end

    # Returns an OctocatHerder::PullRequest::Repo representing
    # information about what the pull request was based on in the pull
    # request.
    def base
      get_detail

      @base_repo ||= OctocatHerder::PullRequest::Repo.new(@raw_detail_hash['base'], connection)
    end

    # A Hash representation of the pull request.  Combines +@raw+, and
    # +@raw_detail_hash+ into a single hash.
    def to_hash
      raw = @raw || {}
      detail = @raw_detail_hash || {}

      raw.merge(detail)
    end

    private

    # Give a full listing of the available information, since we
    # define some of our own methods, and don't have everything in
    # +@raw+.
    def additional_attributes
      attrs = ['user_avatar_url', 'user_url', 'user_id', 'user_login']

      attrs += @raw_detail_hash.keys if @raw_detail_hash
      attrs += ['merged_by_login', 'merged_by_id', 'merged_by_avatar_url', 'merged_by_url']
    end
  end
end
