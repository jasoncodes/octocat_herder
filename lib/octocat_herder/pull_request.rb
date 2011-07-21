require 'cgi'

require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/user'
require 'octocat_herder/pull_request/repo'

class OctocatHerder
  class PullRequest < Base
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

    def self.find_open_for_repository(owner_login, repository_name, conn = OctocatHerder::Connection.new)
      OctocatHerder::PullRequest.find_for_repository(owner_login, repository_name, 'open', conn)
    end

    def self.find_closed_for_repository(owner_login, repository_name, conn = OctocatHerder::Connection.new)
      OctocatHerder::PullRequest.find_for_repository(owner_login, repository_name, 'closed', conn)
    end

    def self.fetch(owner_login, repository_name, pull_request_number, conn = OctocatHerder::Connection.new)
      request = raw_get(
        conn,
        "/repos/#{CGI.escape(owner_login.to_s)}/#{CGI.escape(repository_name.to_s)}/pulls/#{CGI.escape(pull_request_number.to_s)}",
        :headers   => { 'Accept' => 'application/vnd.github-pull.full+json' }
      )

      new(nil, request, conn)
    end

    def initialize(raw_hash, raw_detail_hash = nil, conn = OctocatHerder::Connection.new)
      super raw_hash, conn
      @raw_detail_hash = raw_detail_hash
    end

    def get_detail
      return if @raw_detail_hash

      @raw_detail_hash = raw_get(
        url,
        :headers => { 'Accept' => 'application/vnd.github-pull.full+json' }
      )

      self
    end

    def method_missing(id, *args)
      super
    rescue NoMethodError => e
      get_detail
      return @raw_detail_hash[id.id2name] if @raw_detail_hash and @raw_detail_hash.keys.include?(id.id2name)

      raise e
    end

    # Nested data from the "overview" data.
    def user_avatar_url
      return @raw['user']['avatar_url'] if @raw
      @raw_detail_hash['user']['avatar_url']
    end

    def user_url
      return @raw['user']['url'] if @raw
      @raw_detail_hash['user']['url']
    end

    def user_id
      return @raw['user']['id'] if @raw
      @raw_detail_hash['user']['id']
    end

    def user_login
      return @raw['user']['login'] if @raw
      @raw_detail_hash['user']['login']
    end

    # Return a real user, instead of a hash with the nested data.
    def user
      @user ||= OctocatHerder::User.fetch(user_login, connection)
    end

    # Nested data from the "detail" data.
    def merged_by_login
      get_detail

      @raw_detail_hash['merged_by']['login']
    end

    def merged_by_id
      get_detail

      @raw_detail_hash['merged_by']['id']
    end

    def merged_by_avatar_url
      get_detail

      @raw_detail_hash['merged_by']['avatar_url']
    end

    def merged_by_url
      get_detail

      @raw_detail_hash['merged_by']['url']
    end

    # Return a real user, instead of a hash with the nested data.
    def merged_by
      get_detail

      @merged_by ||= OctocatHerder::User.fetch(merged_by_login, connection)
    end

    # Convert a few things to more Ruby friendly Objects
    def created_at
      parse_date_time(@raw_detail_hash['created_at'])
    end

    def updated_at
      parse_date_time(@raw_detail_hash['updated_at'])
    end

    def closed_at
      parse_date_time(@raw_detail_hash['closed_at'])
    end

    def merged_at
      parse_date_time(@raw_detail_hash['merged_at'])
    end

    def head
      get_detail

      @head_repo ||= OctocatHerder::PullRequest::Repo.new(@raw_detail_hash['head'], connection)
    end

    def base
      get_detail

      @base_repo ||= OctocatHerder::PullRequest::Repo.new(@raw_detail_hash['base'], connection)
    end

    def additional_attributes
      attrs = ['user_avatar_url', 'user_url', 'user_id', 'user_login']

      attrs += @raw_detail_hash.keys if @raw_detail_hash
      attrs += ['merged_by_login', 'merged_by_id', 'merged_by_avatar_url', 'merged_by_url']
    end

    def to_hash
      raw = @raw || {}
      detail = @raw_detail_hash || {}

      raw.merge(detail)
    end
  end
end
