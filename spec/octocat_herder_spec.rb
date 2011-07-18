require 'spec_helper'

describe OctocatHerder do
  describe "without authentication information" do
    it 'creates an unauthenticated connection' do
      OctocatHerder::Connection.expects(:new).with({})

      OctocatHerder.new
    end
  end

  describe "when provided a user name and password to authenticate" do
    it 'creates a connection using the user name and password' do
      OctocatHerder::Connection.expects(:new).with(:user_name => 'user', :password => 'pass')

      OctocatHerder.new :user_name => 'user', :password => 'pass'
    end
  end

  describe "when provided an OAuth2 to authenticate" do
    it 'creates a connection using the OAuth2 Token' do
      OctocatHerder::Connection.expects(:new).with(:oauth2_token => 'token')

      OctocatHerder.new :oauth2_token => 'token'
    end
  end

  it 'fetches the specified user using the current connection' do
    conn = OctocatHerder::Connection.new
    OctocatHerder.any_instance.stubs(:connection).returns conn
    OctocatHerder::User.expects(:fetch).with('bob', conn)

    OctocatHerder.new.user('bob')
  end
end
