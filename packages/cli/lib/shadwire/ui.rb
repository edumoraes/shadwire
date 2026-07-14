# frozen_string_literal: true

module Shadwire
  # Thin terminal-and-agent-friendly IO wrapper. Output streams and the confirm
  # behavior are injectable so commands stay decoupled from Thor and tests can
  # capture output and answer prompts deterministically. With yes: true every
  # confirmation is auto-accepted (the agent/CI path).
  class UI
    def initialize(out: $stdout, err: $stderr, yes: false, confirm_proc: nil)
      @out = out
      @err = err
      @yes = yes
      @confirm_proc = confirm_proc
    end

    def say(message)
      @out.puts(message)
    end

    def warn(message)
      @err.puts(message)
    end

    def error(message)
      @err.puts(message)
    end

    def confirm?(question, default: false)
      return true if @yes
      return !!@confirm_proc.call(question) if @confirm_proc

      prompt(question, default)
    end

    private

    def prompt(question, default)
      suffix = default ? "[Y/n]" : "[y/N]"
      @out.print("#{question} #{suffix} ")
      answer = $stdin.gets
      return default if answer.nil? || answer.strip.empty?

      answer.strip.downcase.start_with?("y")
    end
  end
end
