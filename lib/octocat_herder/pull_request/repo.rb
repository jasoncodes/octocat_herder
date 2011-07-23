require 'octocat_herder/base'
require 'octocat_herder/user'
require 'octocat_herder/repository'

class OctocatHerder
  class PullRequest
    class Repo < ::OctocatHerder::Base
      def user_login
        @raw['user']['login']
      end

      def user_id
        @raw['user']['id']
      end

      def user_avatar_url
        @raw['user']['avatar_url']
      end

      def user_url
        @raw['user']['url']
      end

      def user
        @user = OctocatHerder::User.fetch(@raw['user'], connection)
      end

      def repo
        @repo = OctocatHerder::Repository.new(@raw['repo'], connection)
      end

      private

      def addtional_attributes
        ['user_login', 'user_id', 'user_avatar_url', 'user_url']
      end
    end
  end
end
