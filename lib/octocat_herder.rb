require 'octocat_herder/connection'
require 'octocat_herder/user'

class OctocatHerder
  attr_reader :connection

  def initialize(options={})
    @connection = OctocatHerder::Connection.new options
  end

  def user(user_name)
    OctocatHerder::User.fetch(user_name, connection)
  end
end
