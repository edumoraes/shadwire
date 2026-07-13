# frozen_string_literal: true

require "test_helper"

class ResolverTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures/registry", __dir__)
  FILE_BASE = "file://#{FIXTURES}"

  def setup
    @client = Shadwire::RegistryClient.new(FILE_BASE)
  end

  # --- Leaf (no deps) ---

  def test_expand_single_leaf_returns_that_item
    result = Shadwire::Resolver.expand(["alpha"], @client)
    assert_equal 1, result.size
    assert_equal "alpha", result.first["name"]
  end

  # --- Direct dependency (2 levels) ---

  def test_expand_item_with_one_dep_returns_dep_first
    result = Shadwire::Resolver.expand(["beta"], @client)
    names = result.map { |i| i["name"] }
    assert_equal ["alpha", "beta"], names
  end

  # --- Transitive chain (3 levels): gamma→beta→alpha ---

  def test_expand_transitive_chain_returns_dependency_first_order
    result = Shadwire::Resolver.expand(["gamma"], @client)
    names = result.map { |i| i["name"] }
    assert_equal ["alpha", "beta", "gamma"], names
  end

  def test_alpha_appears_before_beta_in_chain
    result = Shadwire::Resolver.expand(["gamma"], @client)
    names = result.map { |i| i["name"] }
    assert names.index("alpha") < names.index("beta"),
           "alpha must come before beta"
    assert names.index("beta") < names.index("gamma"),
           "beta must come before gamma"
  end

  # --- Diamond: epsilon→{beta,delta}→alpha ---

  def test_expand_diamond_deduplicates_alpha
    result = Shadwire::Resolver.expand(["epsilon"], @client)
    names = result.map { |i| i["name"] }
    assert_equal 1, names.count("alpha"), "alpha must appear exactly once"
    assert_includes names, "epsilon"
  end

  def test_expand_diamond_alpha_before_beta_and_delta
    result = Shadwire::Resolver.expand(["epsilon"], @client)
    names = result.map { |i| i["name"] }
    alpha_i   = names.index("alpha")
    beta_i    = names.index("beta")
    delta_i   = names.index("delta")
    epsilon_i = names.index("epsilon")

    assert alpha_i < beta_i,    "alpha before beta"
    assert alpha_i < delta_i,   "alpha before delta"
    assert beta_i  < epsilon_i, "beta before epsilon"
    assert delta_i < epsilon_i, "delta before epsilon"
  end

  def test_expand_diamond_returns_exactly_four_items
    result = Shadwire::Resolver.expand(["epsilon"], @client)
    assert_equal 4, result.size
    assert_equal %w[alpha beta delta epsilon].sort, result.map { |i| i["name"] }.sort
  end

  # --- Multiple top-level names, de-duplication across calls ---

  def test_expand_multiple_names_deduplicates
    result = Shadwire::Resolver.expand(%w[alpha beta], @client)
    names = result.map { |i| i["name"] }
    assert_equal 1, names.count("alpha"), "alpha must appear once even when requested twice via beta dep"
    assert_includes names, "beta"
  end

  def test_expand_dep_before_dependent_when_both_requested
    result = Shadwire::Resolver.expand(%w[beta alpha], @client)
    names = result.map { |i| i["name"] }
    # alpha was already visited when processing beta, so order is [alpha, beta]
    assert names.index("alpha") < names.index("beta")
  end

  # --- Unknown dependency raises RegistryError ---

  def test_expand_raises_registry_error_on_unknown_dep
    assert_raises(Shadwire::RegistryError) do
      Shadwire::Resolver.expand(["broken"], @client)
    end
  end

  def test_expand_raises_registry_error_for_unknown_top_level_name
    assert_raises(Shadwire::RegistryError) do
      Shadwire::Resolver.expand(["totally_missing"], @client)
    end
  end

  # --- Result items are the full parsed hashes ---

  def test_result_items_are_full_hashes_not_names
    result = Shadwire::Resolver.expand(["beta"], @client)
    result.each do |item|
      assert_kind_of Hash, item
      assert item.key?("files"), "item should have 'files' key"
      assert item.key?("registryDependencies")
    end
  end
end
