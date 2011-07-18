require 'spec_helper'

describe OctocatHerder::Connection do
  it 'accepts an empty argument list (unauthenticated requests)' do
    OctocatHerder::Connection.new
  end

  it 'accepts a user name and password' do
    OctocatHerder::Connection.new :user_name => 'bob', :password => 'pass'
  end

  it 'accepts an OAuth2 Token' do
    OctocatHerder::Connection.new :oauth2_token => 'token goes here'
  end

  it 'requires a user name when given a password' do
    expect { OctocatHerder::Connection.new :password => 'pass' }.to raise_error(
      ArgumentError, 'When providing :user_name or :password, both are required'
    )
  end

  it 'requires a password when given a user name' do
    expect { OctocatHerder::Connection.new :user_name => 'bob' }.to raise_error(
      ArgumentError, 'When providing :user_name or :password, both are required'
    )
  end

  it 'raises an ArgumentError if given an OAuth2 Token and anything else' do
    expect do
      OctocatHerder::Connection.new :oauth2_token => 'token goes here', :invalid => 'argument'
    end.to raise_error(ArgumentError, "Unknown option: 'invalid'")
  end

  it 'raises an ArgumentError if given a user name, password, and anything else' do
    expect do
      OctocatHerder::Connection.new :user_name => 'bob', :password => 'pass', :also => 'invalid'
    end.to raise_error(ArgumentError, "Unknown option: 'also'")
  end

  it 'raises an ArgumentError if given anything other than a user name, password, or OAuth2 Token' do
    expect { OctocatHerder::Connection.new :still => 'bad' }.to raise_error(
      ArgumentError, "Unknown option: 'still'"
    )
  end

  it 'raises an ArgumentError if given anything other than a Hash' do
    expect { OctocatHerder::Connection.new [] }.to raise_error(
      ArgumentError, 'OctocatHerder::Connection does not accept: Array'
    )
  end

  it 'raises an ArgumentError if given an OAuth2 Token and a user name and password' do
    expect do
      OctocatHerder::Connection.new :user_name => 'bob', :password => 'pass', :oauth2_token => 'token'
    end.to raise_error(ArgumentError, 'Cannot provide both an OAuth2 Token, and a user name and password')
  end

  it 'sets the Authorization header when given an OAuth2 Token' do
    conn = OctocatHerder::Connection.new :oauth2_token => 'my_token'

    conn.httparty_options.should == { :headers => { 'Authorization' => 'token my_token' } }
  end

  it 'uses basic auth when given a user name and password' do
    conn = OctocatHerder::Connection.new :user_name => 'user', :password => 'pass'

    conn.httparty_options.should == { :basic_auth => { :username => 'user', :password => 'pass' } }
  end

  it 'should not set any additional options when making unauthenticated requests' do
    conn = OctocatHerder::Connection.new

    conn.httparty_options.should == {}
  end
end
