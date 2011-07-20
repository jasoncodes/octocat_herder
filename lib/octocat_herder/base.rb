require 'cgi'
require 'link_header'
require 'parsedate'
require 'uri'

require 'octocat_herder/connection'

class OctocatHerder
  class Base
    attr_reader :raw, :connection

    def initialize(raw_hash, conn = OctocatHerder::Connection.new)
      @connection = conn
      @raw = raw_hash
    end

    def method_missing(id, *args)
      unless @raw and @raw.keys.include?(id.id2name)
        raise NoMethodError.new("undefined method #{id.id2name} for #{self}:#{self.class}")
      end

      @raw[id.id2name]
    end

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

    def self.raw_get(conn, end_point, options={})
      paginated    = options.delete(:paginated)
      query_params = options.delete(:params) || {}

      query_params[:per_page] = 100 if paginated and query_params[:per_page].nil?
      query_string = query_string_from_params(query_params)

      result = conn.get(end_point + query_string, options)
      raise "Unable to retrieve #{end_point}" unless result

      full_result = result.parsed_response

      if paginated
        if next_page = page_from_headers(result.headers, 'next')
          query_params[:page] = next_page

          new_options = options.merge(query_params)
          new_options[:paginated] = true

          full_result += raw_get(conn, end_point, new_options)
        end
      end

      full_result
    end

    def self.page_from_headers(headers, type)
      link = LinkHeader.parse(headers['link']).find_link(['rel', type])
      return unless link

      CGI.parse(URI.parse(link.href).query)['page'].first
    end

    def self.query_string_from_params(params)
      return '' if params.keys.empty?

      '?' + params.map {|k,v| "#{URI.escape("#{k}")}=#{URI.escape("#{v}")}"}.join('&')
    end

    def additional_attributes
      []
    end

    def parse_date_time(date_time)
      return nil unless date_time

      Time.utc(*ParseDate.parsedate(date_time))
    end
  end
end
