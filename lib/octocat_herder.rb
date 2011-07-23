require 'octocat_herder/connection'
require 'octocat_herder/user'

# This is just a convenience class to serve as a jumping-off point
# into the rest of the GitHub API.  You don't have to use this, if you
# don't want; you can use the other classes directly, constructing
# your own OctocatHerder::Connection to pass to them.
#
# This provides convenience methods for the following:
# * OctocatHerder::User
class OctocatHerder
  # The instance of OctocatHerder::Connection used for making API
  # requests.
  attr_reader :connection

  # Get a new OctocatHerder for use with the GitHub v3 API.
  #
  # @param [Hash] options Passed to OctocatHerder::Connection.new
  def initialize(options={})
    @connection = OctocatHerder::Connection.new(options)
  end

  # Fetch an OctocatHerder::User by using OctocatHerder::User.fetch
  # and the OctocatHerder::Connection from #connection
  #
  # @param [String] user_name The login name of the GitHub user to retrieve.
  def user(user_name)
    OctocatHerder::User.fetch(user_name, connection)
  end
end
