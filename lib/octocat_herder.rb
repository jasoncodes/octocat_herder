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

  # +options+ will be passed to OctocatHerder::Connection.new when
  # constructing the OctocatHerder::Connection used for making API
  # requests.
  def initialize(options={})
    @connection = OctocatHerder::Connection.new(options)
  end

  # Fetch an OctocatHerder::User by using OctocatHerder::User.fetch
  # and the OctocatHerder::Connection from #connection
  def user(user_name)
    OctocatHerder::User.fetch(user_name, connection)
  end
end
