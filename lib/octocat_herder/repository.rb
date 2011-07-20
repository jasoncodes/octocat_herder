require 'cgi'

require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/user'

class OctocatHerder
  class Repository < Base
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

    def owner_login
      @raw['owner']['login']
    end

    def owner_id
      @raw['owner']['id']
    end

    def owner_avatar_url
      @raw['owner']['avatar_url']
    end

    def owner_url
      @raw['owner']['url']
    end

    def owner
      OctocatHerder::User.fetch(owner_login, connection)
    end

    def open_pull_requests
      OctocatHerder::PullRequest.find_for_repository(owner_login, name, 'open')
    end

    def closed_pull_requests
      OctocatHerder::PullRequest.find_for_repository(owner_login, name, 'closed')
    end

    def source
      return unless @raw['source']

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
