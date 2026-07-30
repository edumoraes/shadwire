# frozen_string_literal: true

require "test_helper"
require "json"
require "webrick"

class RegistryClientFileTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures/registry", __dir__)
  FILE_BASE = "file://#{FIXTURES}" # no trailing slash — matches how real URLs look

  def setup
    @client = Shadwire::RegistryClient.new(FILE_BASE)
  end

  # --- #index ---

  def test_index_returns_parsed_index_json
    idx = @client.index
    assert_equal "shadwire", idx["name"]
    assert_equal "0.1.0",    idx["version"]
    assert_kind_of Array, idx["items"]
    assert idx["items"].any? { |i| i["name"] == "alpha" }
  end

  def test_index_is_memoized_within_the_instance
    first  = @client.index
    second = @client.index
    assert_same first, second, "Expected the same object from both calls"
  end

  # --- #item ---

  def test_item_returns_parsed_item_json
    item = @client.item("alpha")
    assert_equal "alpha",     item["name"]
    assert_equal "component", item["type"]
    assert_kind_of Array, item["files"]
  end

  def test_item_is_memoized_per_name
    first  = @client.item("beta")
    second = @client.item("beta")
    assert_same first, second
  end

  def test_item_caches_independently_per_name
    alpha = @client.item("alpha")
    beta  = @client.item("beta")
    refute_same alpha, beta
  end

  def test_item_raises_registry_error_for_missing_item
    err = assert_raises(Shadwire::RegistryError) do
      @client.item("nonexistent")
    end
    assert_match "nonexistent", err.message
  end

  def test_registry_error_message_includes_url
    err = assert_raises(Shadwire::RegistryError) do
      @client.item("nonexistent")
    end
    assert_match "nonexistent.json", err.message
  end

  # --- base URL with trailing slash is normalised ---

  def test_trailing_slash_on_base_url_is_tolerated
    client_with_slash = Shadwire::RegistryClient.new("#{FILE_BASE}/")
    idx = client_with_slash.index
    assert_equal "shadwire", idx["name"]
  end
end

class RegistryClientHttpTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures/registry", __dir__)

  def setup
    @server = WEBrick::HTTPServer.new(
      Port: 0,
      DocumentRoot: FIXTURES,
      Logger: WEBrick::Log.new(IO::NULL),
      AccessLog: []
    )
    @thread = Thread.new { @server.start }

    port = @server.config[:Port]
    # Poll until the server accepts connections (avoids a fixed sleep).
    deadline = Time.now + 5
    begin
      TCPSocket.new("127.0.0.1", port).close
    rescue Errno::ECONNREFUSED
      raise "WEBrick did not start within 5 s" if Time.now > deadline
      sleep 0.01
      retry
    end

    @base = "http://127.0.0.1:#{port}" # no trailing slash
    @client = Shadwire::RegistryClient.new(@base)
  end

  def teardown
    @server.shutdown
    @thread.join
  end

  def test_index_fetched_over_http
    idx = @client.index
    assert_equal "shadwire", idx["name"]
    assert_equal "0.1.0",    idx["version"]
  end

  def test_item_fetched_over_http
    item = @client.item("alpha")
    assert_equal "alpha", item["name"]
  end

  def test_item_raises_registry_error_for_404
    err = assert_raises(Shadwire::RegistryError) do
      @client.item("nonexistent")
    end
    assert_match "nonexistent", err.message
  end

  def test_http_index_memoized
    first  = @client.index
    second = @client.index
    assert_same first, second
  end
end

# A registry that has moved — GitHub Pages answers 301 for every path once a
# custom domain is configured, so a client that treats 3xx as failure breaks
# for everyone whose shadwire.json still records the old URL.
class RegistryClientRedirectTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures/registry", __dir__)

  def setup
    @server = WEBrick::HTTPServer.new(
      Port: 0,
      DocumentRoot: FIXTURES,
      Logger: WEBrick::Log.new(IO::NULL),
      AccessLog: []
    )
    @port = @server.config[:Port]
    origin = "http://127.0.0.1:#{@port}"

    # /moved/<file> → 301 → /<file>
    @server.mount_proc("/moved") do |req, res|
      res.status = 301
      res["location"] = "#{origin}#{req.path.delete_prefix("/moved")}"
    end
    # /found/<file> → 302 → /<file>
    @server.mount_proc("/found") do |req, res|
      res.status = 302
      res["location"] = "#{origin}#{req.path.delete_prefix("/found")}"
    end
    # /relative/<file> → 301 → /<file>, but as a bare path (RFC 7231 allows it)
    @server.mount_proc("/relative") do |req, res|
      res.status = 301
      res["location"] = req.path.delete_prefix("/relative")
    end
    # /hop1 → /hop2 → real file: more than one redirect must still resolve.
    @server.mount_proc("/hop1") do |req, res|
      res.status = 301
      res["location"] = "#{origin}/hop2#{req.path.delete_prefix("/hop1")}"
    end
    @server.mount_proc("/hop2") do |req, res|
      res.status = 301
      res["location"] = "#{origin}#{req.path.delete_prefix("/hop2")}"
    end
    # /loop/<file> → 301 → itself, forever.
    @server.mount_proc("/loop") do |req, res|
      res.status = 301
      res["location"] = "#{origin}#{req.path}"
    end
    # /nowhere/<file> → 301 with no Location header at all.
    @server.mount_proc("/nowhere") do |_req, res|
      res.status = 301
    end

    @thread = Thread.new { @server.start }

    deadline = Time.now + 5
    begin
      TCPSocket.new("127.0.0.1", @port).close
    rescue Errno::ECONNREFUSED
      raise "WEBrick did not start within 5 s" if Time.now > deadline
      sleep 0.01
      retry
    end

    @origin = origin
  end

  def teardown
    @server.shutdown
    @thread.join
  end

  def test_index_follows_a_301_redirect
    client = Shadwire::RegistryClient.new("#{@origin}/moved")
    assert_equal "shadwire", client.index["name"]
  end

  def test_item_follows_a_301_redirect
    client = Shadwire::RegistryClient.new("#{@origin}/moved")
    assert_equal "alpha", client.item("alpha")["name"]
  end

  def test_index_follows_a_302_redirect
    client = Shadwire::RegistryClient.new("#{@origin}/found")
    assert_equal "shadwire", client.index["name"]
  end

  def test_follows_a_redirect_to_a_relative_location
    client = Shadwire::RegistryClient.new("#{@origin}/relative")
    assert_equal "shadwire", client.index["name"]
  end

  def test_follows_a_chain_of_redirects
    client = Shadwire::RegistryClient.new("#{@origin}/hop1")
    assert_equal "shadwire", client.index["name"]
  end

  def test_redirect_loop_raises_registry_error_instead_of_hanging
    client = Shadwire::RegistryClient.new("#{@origin}/loop")
    err = assert_raises(Shadwire::RegistryError) { client.index }
    assert_match(/redirect/i, err.message)
  end

  def test_redirect_without_a_location_header_raises_registry_error
    client = Shadwire::RegistryClient.new("#{@origin}/nowhere")
    err = assert_raises(Shadwire::RegistryError) { client.index }
    assert_match(/redirect/i, err.message)
  end

end

# The redirect policy itself, without a socket in the way.
class RegistryClientRedirectTargetTest < Minitest::Test
  def target(from, location)
    Shadwire::RegistryClient.redirect_target(URI.parse(from), location)
  end

  def test_absolute_location_is_used_as_is
    uri = target("http://a.example/r/index.json", "http://b.example/r/index.json")
    assert_equal "http://b.example/r/index.json", uri.to_s
  end

  def test_relative_location_resolves_against_the_current_url
    uri = target("http://a.example/old/index.json", "/r/index.json")
    assert_equal "http://a.example/r/index.json", uri.to_s
  end

  def test_http_to_https_upgrade_is_allowed
    uri = target("http://a.example/r/index.json", "https://a.example/r/index.json")
    assert_equal "https://a.example/r/index.json", uri.to_s
  end

  # A registry serves source code that gets written into the user's app, so a
  # redirect must never silently drop TLS. (GitHub Pages answers `Location:
  # http://…` for a custom domain until "Enforce HTTPS" is on.)
  def test_https_to_http_downgrade_is_refused
    err = assert_raises(Shadwire::RegistryError) do
      target("https://a.example/r/index.json", "http://a.example/r/index.json")
    end
    assert_match(/https/i, err.message)
  end

  def test_missing_location_is_refused
    err = assert_raises(Shadwire::RegistryError) do
      target("https://a.example/r/index.json", nil)
    end
    assert_match(/redirect/i, err.message)
  end
end
