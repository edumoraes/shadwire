# frozen_string_literal: true

require "json"

module Shadwire
  # Fetches the published registry over file:// or http(s)://.
  # Both #index and #item are memoized within the instance.
  class RegistryClient
    def initialize(base_url)
      # Normalise: drop any trailing slash so URL building is consistent.
      @base_url = base_url.chomp("/")
      @cache = {}
    end

    # Returns the parsed index.json hash (memoized).
    def index
      @cache[:__index__] ||= fetch("index.json")
    end

    # Returns the parsed {name}.json hash (memoized per name).
    # Raises Shadwire::RegistryError if the item is not found.
    def item(name)
      @cache[name] ||= fetch("#{name}.json", name:)
    end

    private

    def fetch(filename, name: nil)
      url = "#{@base_url}/#{filename}"
      if @base_url.start_with?("file://")
        fetch_file(url, name:)
      else
        fetch_http(url, name:)
      end
    end

    def fetch_file(url, name: nil)
      # file:///abs/path/... → /abs/path/...
      local_path = url.sub(/\Afile:\/\//, "")
      unless File.exist?(local_path)
        raise RegistryError, missing_message(name, url)
      end

      parse(File.read(local_path), url)
    end

    def fetch_http(url, name: nil)
      require "net/http"
      require "uri"

      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise RegistryError, missing_message(name, url, code: response.code)
      end

      parse(response.body, url)
    rescue SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
      # An offline machine, a DNS failure or a TLS problem is an ordinary
      # condition here, not something to surface as a Ruby backtrace.
      raise RegistryError, "Could not reach the registry at #{url}: #{e.message}"
    end

    # A registry that serves HTML (a 200 error page, a captive portal) would
    # otherwise blow up as a bare JSON::ParserError.
    def parse(body, url)
      JSON.parse(body)
    rescue JSON::ParserError => e
      raise RegistryError, "Registry response from #{url} is not valid JSON: #{e.message}"
    end

    def missing_message(name, url, code: nil)
      label = name ? "item #{name.inspect}" : "index"
      suffix = code ? " (HTTP #{code})" : ""
      "Registry #{label} not found at #{url}#{suffix}"
    end
  end
end
