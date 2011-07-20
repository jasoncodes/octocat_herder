require 'octocat_herder/base'
require 'octocat_herder/connection'
require 'octocat_herder/repository'

class OctocatHerder
  class User < Base
    def self.fetch(user_name, conn = OctocatHerder::Connection.new)
      user = raw_get(conn, "/users/#{user_name}")

      OctocatHerder::User.new(user, conn)
    end

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
