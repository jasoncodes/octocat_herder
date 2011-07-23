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

    # Provide the +.list_all+, +.list_private+, +.list_public+, and
    # +.list_member+ methods for retrieving specific types of
    # repositories from a given user.  These methods take a mandatory
    # user login name, and an optional OctocatHerder::Connection to
    # use.
    def self.method_missing(id, *args)
      if id.id2name =~ /list_(.+)/
        repository_type = Regexp.last_match(1)
        if ['all', 'private', 'public', 'member'].include? repository_type
          arguments = [args[0], args[1], repository_type]
          arguments << args[2] unless args[2].nil?

          return self.list(*arguments)
        end
      end

      raise NoMethodError.new("undefined method #{id.id2name} for #{self}:#{self.class}")
    end

    # The login name of the owner of the repository.
    def owner_login
      @raw['owner']['login']
    end

    # The ID number of the owner of the repository.
    def owner_id
      @raw['owner']['id']
    end

    # The URL to the avatar image of the owner of the repository.
    def owner_avatar_url
      @raw['owner']['avatar_url']
    end

    # The URL of the owner of the repository.
    def owner_url
      @raw['owner']['url']
    end

    # Return an OctocatHerder::User representing the owner of the
    # repository.
    #
    # This is cached locally to the instance of
    # OctocatHerder::Repository, but will make an additional API
    # request to populate it initially.
    def owner
      @owner ||= OctocatHerder::User.fetch(owner_login, connection)
    end

    # Return a list of OctocatHerder::PullRequest representing the
    # open pull requests for the repository.
    #
    # This is _not_ cached, and will make at least one API request
    # every time it is called.
    def open_pull_requests
      OctocatHerder::PullRequest.find_open_for_repository(owner_login, name, connection)
    end

    # Return a list of OctocatHerder::PullRequest representing the
    # closed pull requests for the repository.
    #
    # This is _not_ cached, and will make at least one API request
    # every time it is called.
    def closed_pull_requests
      OctocatHerder::PullRequest.find_closed_for_repository(owner_login, name, connection)
    end

    # Return an OctocatHerder::Repository representing the source
    # repository that this one was forked from, or +nil+ if this
    # repository is not a fork.
    def source
      return nil unless @raw['source']

      OctocatHerder::Repository.new(@raw['source'], connection)
    end

    private

    def self.list(login, account_type, repository_type, conn = OctocatHerder::Connection.new)
      url_base = case account_type
                   when "User"         then "users"
                   when "Organization" then "orgs"
                 else
                   raise ArgumentError.new("Unknown account type: #{account_type}")
                 end

      repositories = raw_get(
        conn,
        "/#{url_base}/#{CGI.escape(login)}/repos",
        :paginated => true,
        :params    => { :type => repository_type }
      )

      repositories.map do |repo|
        new(repo, conn)
      end
    end

    def self.fetch(login, repository_name, conn = OctocatHerder::Connection.new)
      repo_data = raw_get(
        conn,
        "/repos/#{CGI.escape(login)}/#{CGI.escape(repository_name)}"
      )

      new(repo_data, conn)
    end

    def additional_attributes
      ['owner_login', 'owner_id', 'owner_avatar_url', 'owner_url']
    end
  end
end
