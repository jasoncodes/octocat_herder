require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/repository'

class OctocatHerder
  # Interface to the GitHub v3 API for interacting with users.
  #
  # Currently, this only supports retrieval of information about the
  # requested user.
  class User
    include OctocatHerder::Base

    # Return an OctocatHerder::User representing the requested user.
    #
    # [user_name] The login name of the desired user.
    # [conn] An optional OctocatHerder::Connection to use for the API requests.  Defaults to unauthenticated requests.
    def self.fetch(user_name, conn = OctocatHerder::Connection.new)
      user = raw_get(conn, "/users/#{user_name}")

      OctocatHerder::User.new(user, conn)
    end

    # Return a list of all repositories owned by the user.
    #
    # This is cached locally to the OctocatHerder::User instance, but
    # at least one API request will be made to populate it initially.
    def repositories
      @repositories ||= OctocatHerder::Repository.list_all(login, user_type, connection)
    end

    # The user id can't be handled by the method_missing magic from
    # OctocatHerder::Base, since the id method returns the object id.
    def user_id
      @raw['id']
    end

    # The user type can't be handled by the method_missing magic from
    # OctocatHerder::Base, since 'type' is the deprecated form of the
    # method 'class'.
    def user_type
      @raw['type']
    end

    private

    def additional_attributes
      ['user_id', 'user_type']
    end
  end
end
