# frozen_string_literal: true

require "json"
require "uri"

module Shadwire
  # Fetches the published registry over file:// or http(s)://.
  # Both #index and #item are memoized within the instance.
  class RegistryClient
    # Registries move: GitHub Pages answers 301 for every path once a custom
    # domain is configured. Follow a few hops, then assume a misconfiguration
    # rather than chasing a chain forever.
    MAX_REDIRECTS = 5

    # Resolves a redirect's Location against the URL it came from, rejecting
    # redirects we must not follow. A registry serves source code that gets
    # written into the user's app, so a redirect may upgrade to HTTPS but never
    # drop it (GitHub Pages answers `Location: http://…` for a custom domain
    # until "Enforce HTTPS" is on).
    def self.redirect_target(from_uri, location)
      if location.to_s.strip.empty?
        raise RegistryError, "Registry redirect from #{from_uri} has no Location header"
      end

      begin
        target = from_uri + location.strip
      rescue URI::Error => e
        raise RegistryError,
              "Registry redirect from #{from_uri} has an unusable Location (#{location}): #{e.message}"
      end

      if from_uri.scheme == "https" && target.scheme != "https"
        raise RegistryError,
              "Registry redirect from #{from_uri} drops HTTPS (to #{target}); refusing to follow it"
      end

      target
    end

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

      uri = URI.parse(url)
      seen = []
      response = nil

      (MAX_REDIRECTS + 1).times do
        if seen.include?(uri.to_s)
          raise RegistryError, "Registry redirect from #{url} loops back to #{uri}"
        end
        seen << uri.to_s

        response = Net::HTTP.get_response(uri)
        break unless response.is_a?(Net::HTTPRedirection)

        uri = self.class.redirect_target(uri, response["location"])
      end

      if response.is_a?(Net::HTTPRedirection)
        raise RegistryError,
              "Registry at #{url} redirected more than #{MAX_REDIRECTS} times (last: #{uri})"
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise RegistryError, missing_message(name, uri, code: response.code)
      end

      parse(response.body, uri)
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
