require 'octocat_herder/base'
require 'octocat_herder/user'
require 'octocat_herder/repository'

class OctocatHerder
  class PullRequest
    # A representation of the repsoitory meta-data returned from the
    # pull request API.  This is only ever useful when returned from
    # OctocatHerder::PullRequest#head or
    # OctocatHerder::PullRequest#base.
    class Repo
      include OctocatHerder::Base

      # The login name of the owner of this repository.
      #
      # @since 0.0.1
      # @return [String]
      def user_login
        @raw['user']['login']
      end

      # The ID number of the owner of this repository.
      #
      # @since 0.0.1
      # @return [Integer]
      def user_id
        @raw['user']['id']
      end

      # The URL to the avatar image of the owner of this repository.
      #
      # @since 0.0.1
      # @return [String]
      def user_avatar_url
        @raw['user']['avatar_url']
      end

      # The URL of the owner of this repository.
      #
      # @since 0.0.1
      # @return [String]
      def user_url
        @raw['user']['url']
      end

      # The owner of this repository.
      #
      # @note This is cached locally to the instance of OctocatHerder::PullRequest::Repo, but will make an additional API request to populate it initially.
      #
      # @since 0.0.1
      # @return [OctocatHerder::User]
      def user
        @user ||= OctocatHerder::User.fetch(@raw['user'], connection)
      end

      # The detailed information about the repository.
      #
      # @since 0.0.1
      # @return [OctocatHerder::Repository]
      def repo
        @repo ||= OctocatHerder::Repository.new(@raw['repo'], connection)
      end

      private

      def addtional_attributes
        ['user_login', 'user_id', 'user_avatar_url', 'user_url']
      end
    end
  end
end
