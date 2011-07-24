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

    # Find a user by login name
    #
    # @since 0.0.1
    # @param [String] user_name The login name of the desired user.
    #
    # @param [OctocatHerder::Connection] conn Defaults to
    #   unauthenticated requests.
    #
    # @return [OctocatHerder::User]
    def self.fetch(user_name, conn = OctocatHerder::Connection.new)
      user = conn.get("/users/#{user_name}")

      OctocatHerder::User.new(user, conn)
    end

    # All repositories owned by the user.
    #
    # @note This is cached locally to the {OctocatHerder::User}
    #   instance, but at least one API request will be made to
    #   populate it initially.
    #
    # @since 0.0.1
    # @return [Array<OctocatHerder::Repository>]
    def repositories
      @repositories ||= OctocatHerder::Repository.list_all(login, user_type, connection)
    end

    # The ID number of the user.
    #
    # @since 0.0.1
    # @return [Integer]
    def user_id
      # The user id can't be handled by the method_missing magic from
      # OctocatHerder::Base, since the id method returns the object
      # id.
      @raw['id']
    end

    # The type of account.  Typically one of +'User'+, or
    # +'Organization'+.
    #
    # @since 0.0.1
    # @return [String]
    def user_type
      # The user type can't be handled by the method_missing magic
      # from OctocatHerder::Base, since 'type' is the deprecated form
      # of the method 'class'.
      @raw['type']
    end

    private

    # @api private
    # @since 0.0.1
    def additional_attributes
      ['user_id', 'user_type']
    end
  end
end
