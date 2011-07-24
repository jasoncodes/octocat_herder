# Octocat Herder [![Build status](http://travis-ci.org/jhelwig/octocat_herder.png)](http://travis-ci.org/jhelwig/octocat_herder)

Octocat Herder is a wrapper for the GitHub v3 API.

## On-line documentation

* [rdoc.info](http://rdoc.info/gems/octocat_herder/frames)

## Requirements

* Gems
  * link_header
  * httparty

## Basic usage

Quick start:

    require 'rubygems'
    => true
    require 'octocat_herder'
    => true

    herder = OctocatHerder.new
    => #<OctocatHerder:0x7f792d3c4918 ...>

    me = herder.user 'jhelwig'
    => #<OctocatHerder::User:0x7f792d3b6070 ...>

    me.html_url
    => "https://github.com/jhelwig"

    me.available_attributes.sort
    => ["avatar_url", "bio", "blog", "company", "created_at", "email", "followers", "following", "hireable", "html_url", "location", "login", "name", "public_gists", "public_repos", "url", "user_id", "user_type"]

    repos = me.repositories
    => [#<OctocatHerder::Repository:0x7f792d364bf8 ...>, #<OctocatHerder::Repository:0x7f792d364bd0 ..>, #<OctocatHerder::Repository:0x7f792d364ba8 ...>, ...]


## Contributing to octocat-herder

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bug-fix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Jacob Helwig. See LICENSE.txt for
further details.

