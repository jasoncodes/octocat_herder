require 'cgi'

require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/user'

class OctocatHerder
  # Interface to the GitHub v3 API for interacting with repositories.
  #
  # Currently, this only supports retrieval of information about the
  # repository itself, not any updating/creation.
  class Repository
    include OctocatHerder::Base

    # @overload list_all(login_name, account_type, conn = OctocatHerder::Connection.new)
    # @overload list_private(login_name, account_type, conn)
    # @overload list_public(login_name, account_type, conn = OctocatHerder::Connection.new)
    # @overload list_member(login_name, account_type, conn = OctocatHerder::Connection.new)
    #
    # Fetch all, private, public, or member repositories for the specified user.
    #
    # @since 0.0.1
    #
    # @raise [ArgumentError] If no conn is not provided when listing
    #   private repositories.
    #
    # @param [String] login_name The login name of the user.
    #
    # @param ['User', 'Organization'] Whether login_name is for a user
    #   or organization.
    #
    # @param [OctocatHerder::Connection] conn Defaults to
    #   unauthenticated requests.
    #
    # @return [Array<OctocatHerder::Repository>]
    def self.method_missing(id, *args)
      if id.id2name =~ /list_(.+)/
        repository_type = Regexp.last_match(1)
        if ['all', 'private', 'public', 'member'].include? repository_type
          if repository_type == 'private' and args[2].nil?
            raise ArgumentError.new("Must specify a connection when listing private repositories.")
          end

          arguments = [args[0], args[1], repository_type]
          arguments << args[2] unless args[2].nil?

          return self.list(*arguments)
        end
      end

      raise NoMethodError.new("undefined method #{id.id2name} for #{self}:#{self.class}")
    end

    # The login name of the owner of the repository.
    #
    # @since 0.0.1
    # @return [String]
    def owner_login
      @raw['owner']['login']
    end

    # The ID number of the owner of the repository.
    #
    # @since 0.0.1
    # @return [Integer]
    def owner_id
      @raw['owner']['id']
    end

    # The URL to the avatar image of the owner of the repository.
    #
    # @since 0.0.1
    # @return [String]
    def owner_avatar_url
      @raw['owner']['avatar_url']
    end

    # The URL of the owner of the repository.
    #
    # @since 0.0.1
    # @return [String]
    def owner_url
      @raw['owner']['url']
    end

    # The owner of the repository.
    #
    # @note This is cached locally to the instance of OctocatHerder::Repository, but will make an additional API request to populate it initially.
    #
    # @since 0.0.1
    # @return [OctocatHerder::User]
    def owner
      @owner ||= OctocatHerder::User.fetch(owner_login, connection)
    end

    # The open pull requests for the repository.
    #
    # @note This is _not_ cached, and will make at least one API request every time it is called.
    #
    # @since 0.0.1
    # @return [Array<OctocatHerder::PullRequest>]
    def open_pull_requests
      OctocatHerder::PullRequest.find_open_for_repository(owner_login, name, connection)
    end

    # The closed pull requests for the repository.
    #
    # @note This is _not_ cached, and will make at least one API request every time it is called.
    #
    # @since 0.0.1
    # @return [Array<OctocatHerder::PullRequest>]
    def closed_pull_requests
      OctocatHerder::PullRequest.find_closed_for_repository(owner_login, name, connection)
    end

    # The source repository that this one was forked from, or +nil+ if
    # this repository is not a fork.
    #
    # @since 0.0.1
    # @return [OctocatHerder::Repository, nil]
    def source
      return nil unless @raw['source']

      OctocatHerder::Repository.new(@raw['source'], connection)
    end

    # Fetch repositories of the specified type, owned by the given login
    #
    # @since 0.0.1
    #
    # @raise [ArgumentError] If provided an unauthenticated
    #   OctocatHerder::Connection and repository_type is 'private'.
    #
    # @raise [ArgumentError] If account_type is not one of the strings
    #   'User', or 'Organization'.
    #
    # @raise [ArgumentError] If repository_type is not one of the
    #   strings 'all', 'private', 'public', or 'member'.
    #
    # @param [String] login Login name of the account.
    #
    # @param ['User', 'Organization'] account_type Type of the
    #   specified login.
    #
    # @param ['all', 'private', 'public', 'member'] repository_type
    #   Which set of repositories to list.
    #
    # @param [OctocatHerder::Connection] conn Default to
    #   unauthenticated requests.
    #
    # @return [Array<OctocatHerder::Repository>]
    def self.list(login, account_type, repository_type, conn = OctocatHerder::Connection.new)
      url_base = case account_type
                   when "User"         then "users"
                   when "Organization" then "orgs"
                 else
                   raise ArgumentError.new("Unknown account type: #{account_type}")
                 end

      raise ArgumentError.new(
        "Unknown repository type: #{repository_type}"
      ) unless ['all', 'private', 'public', 'member'].include?(repository_type)

      raise ArgumentError.new(
        "Must provide an authenticated OctocatHerder::Connection when listing private repositories."
      ) if !conn.authenticated_requests? && repository_type == 'private'

      repositories = conn.get(
        "/#{url_base}/#{CGI.escape(login)}/repos",
        :paginated => true,
        :params    => { :type => repository_type }
      )

      repositories.map do |repo|
        new(repo, conn)
      end
    end

    def self.fetch(login, repository_name, conn = OctocatHerder::Connection.new)
      repo_data = conn.get(
        "/repos/#{CGI.escape(login)}/#{CGI.escape(repository_name)}"
      )

      new(repo_data, conn)
    end

    private

    def additional_attributes
      ['owner_login', 'owner_id', 'owner_avatar_url', 'owner_url']
    end
  end
end
