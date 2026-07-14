# frozen_string_literal: true

require "test_helper"

class DifferTest < Minitest::Test
  def test_identical_text_produces_no_diff
    assert_equal "", Shadwire::Differ.unified("a\nb\nc\n", "a\nb\nc\n")
  end

  def test_changed_line_shows_removal_and_addition
    diff = Shadwire::Differ.unified("a\nOLD\nc\n", "a\nNEW\nc\n")

    assert_includes diff, "-OLD"
    assert_includes diff, "+NEW"
    assert_includes diff, " a"     # surrounding context is kept
  end

  def test_added_line_shows_addition
    diff = Shadwire::Differ.unified("a\nb\n", "a\nb\nc\n")

    assert_includes diff, "+c"
    refute(diff.lines.any? { |line| line.start_with?("-") }, "nothing was removed")
  end

  def test_removed_line_shows_removal
    diff = Shadwire::Differ.unified("a\nb\nc\n", "a\nc\n")

    assert_includes diff, "-b"
  end

  def test_output_carries_a_hunk_header
    diff = Shadwire::Differ.unified("a\nb\n", "a\nB\n")

    assert_match(/^@@ -\d+,\d+ \+\d+,\d+ @@/, diff)
  end

  def test_path_adds_file_headers
    diff = Shadwire::Differ.unified("a\n", "b\n", path: "app/x.rb")

    assert_includes diff, "--- a/app/x.rb"
    assert_includes diff, "+++ b/app/x.rb"
  end
end
