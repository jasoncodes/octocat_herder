require 'cgi'
require 'link_header'

begin
  require 'parsedate'
rescue LoadError
end

require 'uri'

require 'octocat_herder/connection'

class OctocatHerder
  # This provides most of the functionality to interact with the
  # GitHub v3 API.
  module Base
    # The re-hydrated JSON retrieved from the GitHub API.
    #
    # @since 0.0.1
    # @return [Hash]
    attr_reader :raw

    # Our {OctocatHerder::Connection}, so we can make more requests
    # based on the information we retrieved from the GitHub API.
    #
    # @since 0.0.1
    # @return [OctocatHerder::Connection]
    attr_reader :connection

    # @api private
    # @since 0.0.1
    #
    # @param [Hash] raw_hash The re-hydrated JSON received from the
    #   GitHub API via {OctocatHerder::Connection}.
    #
    # @param [OctocatHerder::Connection] conn If not provided requests
    #   will be unauthenticated.
    def initialize(raw_hash, conn = OctocatHerder::Connection.new)
      @connection = conn
      @raw = raw_hash
    end

    # We use the +method_missing+ magic to create accessors for the
    # information we got back from the GitHub API.  You can get a list
    # of all of the available things from {#available_attributes}.
    #
    # @since 0.0.1
    def method_missing(id, *args)
      unless @raw and @raw.keys.include?(id.id2name)
        raise NoMethodError.new("undefined method #{id.id2name} for #{self}:#{self.class}")
      end

      @raw[id.id2name]
    end

    # This returns a list of the things that the API request returned
    # to us.
    #
    # @since 0.0.1
    #
    # @return [Array<String>] Names of available methods providing
    #   additional detail about the object.
    def available_attributes
      attrs = []
      attrs += @raw.keys.reject do |k|
        [
          'id',
          'type',
        ].include? k
      end if @raw

      (attrs + additional_attributes).uniq
    end

    private

    # Intended to be overridden in classes using {OctocatHerder::Base},
    # so they can make the methods they define show up in
    # {#available_attributes}.
    #
    # @since 0.0.1
    def additional_attributes
      []
    end

    # @since 0.0.1
    def parse_date_time(date_time)
      return nil unless date_time

      if defined? ParseDate
        Time.utc(*ParseDate.parsedate(date_time))
      else
        DateTime.parse date_time
      end
    end
  end
end
