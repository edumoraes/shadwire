# frozen_string_literal: true

module Shadwire
  # Minimal line-based unified diff, stdlib only — no diff gem. Used by `diff`
  # and `update` to show how a locally-edited file drifts from the registry copy.
  # Returns "" when the two texts are identical. Output normalizes line endings
  # (each rendered line is chomped) since it is for human display, not patching;
  # byte-exact drift detection is done by the caller comparing raw content.
  module Differ
    CONTEXT = 3

    # An edit is [kind, old_index_or_nil, new_index_or_nil, text] where kind is
    # one of :eq, :del, :ins.

    module_function

    def unified(old_text, new_text, path: nil)
      return "" if old_text == new_text

      edits = backtrack(lcs_table(old_text.lines, new_text.lines), old_text.lines, new_text.lines)
      hunks = group(edits)
      return "" if hunks.empty?

      render(hunks, path)
    end

    # Longest-common-subsequence length table over the two line arrays.
    def lcs_table(a, b)
      table = Array.new(a.length + 1) { Array.new(b.length + 1, 0) }
      a.each_index do |i|
        b.each_index do |j|
          table[i + 1][j + 1] = a[i] == b[j] ? table[i][j] + 1 : [table[i][j + 1], table[i + 1][j]].max
        end
      end
      table
    end

    # Walks the table from the bottom-right to recover the edit sequence.
    def backtrack(table, a, b)
      edits = []
      i = a.length
      j = b.length
      while i.positive? || j.positive?
        if i.positive? && j.positive? && a[i - 1] == b[j - 1]
          edits.unshift([:eq, i - 1, j - 1, a[i - 1]])
          i -= 1
          j -= 1
        elsif j.positive? && (i.zero? || table[i][j - 1] >= table[i - 1][j])
          edits.unshift([:ins, nil, j - 1, b[j - 1]])
          j -= 1
        else
          edits.unshift([:del, i - 1, nil, a[i - 1]])
          i -= 1
        end
      end
      edits
    end

    # Groups changed edits into hunks, each padded with CONTEXT lines and merged
    # when they overlap.
    def group(edits)
      ranges = []
      edits.each_index.select { |k| edits[k][0] != :eq }.each do |k|
        lo = [k - CONTEXT, 0].max
        hi = [k + CONTEXT, edits.length - 1].min
        if ranges.any? && lo <= ranges.last[1] + 1
          ranges.last[1] = [ranges.last[1], hi].max
        else
          ranges << [lo, hi]
        end
      end
      ranges.map { |lo, hi| edits[lo..hi] }
    end

    def render(hunks, path)
      lines = []
      lines << "--- a/#{path}" << "+++ b/#{path}" if path
      hunks.each do |hunk|
        lines << header(hunk)
        hunk.each { |kind, _, _, text| lines << "#{prefix(kind)}#{text.chomp}" }
      end
      "#{lines.join("\n")}\n"
    end

    def header(hunk)
      old = hunk.reject { |kind, *| kind == :ins }
      new = hunk.reject { |kind, *| kind == :del }
      old_start = (old.first&.at(1) || 0) + 1
      new_start = (new.first&.at(2) || 0) + 1
      "@@ -#{old_start},#{old.size} +#{new_start},#{new.size} @@"
    end

    def prefix(kind)
      { eq: " ", del: "-", ins: "+" }.fetch(kind)
    end
  end
end
