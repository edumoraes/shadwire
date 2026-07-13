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
