require 'time'

module Notarius
  ##
  # Handles formatting of log messages. It's compatable with Ruby's
  # +Logger::Formatter+ class, but has its own opinions:
  #
  # * Whitespace in the message is converted to spaces.
  # * Output is truncated to 140 characters.
  # * Timestamps are formatted as ISO 8601 in UTC.
  # * Lines in call stacks are prefixed with !'s.
  # * Any of the arguments to #call can be nil.

  class Formatter
    ##
    # This is the interface Ruby's +Logger+ class expects.
    # @param [String] severity the severity level of the message
    # @param [Date] timestamp the timestamp for the message
    # @param [Object] application unused
    # @param [String, #message, #backtrace, #inspect] message
    #   the message to log
    # @return [String] formatted as "SEVERITY [timestamp] message\\n"

    def call severity, timestamp, application, message
      lines = []
      lines << format_message(severity, timestamp, message)
      lines << format_backtrace(message)
      lines.flatten!
      lines.map! { |line| make_tweetable(line) }
      "#{lines.join("\n")}\n"
    end


    private

    def format_message severity, timestamp, message
      severity = format_severity severity
      timestamp = format_timestamp timestamp
      message = parse_message message
      "#{severity} #{timestamp} #{message}".strip
    end

    def format_backtrace message
      trace = message.respond_to?(:backtrace) ? [message.backtrace] : []
      trace.flatten!
      trace.compact!
      trace.map { |line| "! #{clean_message(line)}" }
    end

    def format_severity severity
      severity.gsub(/\s+/, '').upcase if severity
    end

    def parse_message message
      message = message.message if message.respond_to?(:message)
      clean_message(message || '')
    end

    def clean_message message
      message = message.inspect unless message.kind_of?(String)
      message.gsub(/\s+/, ' ').strip
    end

    def format_timestamp timestamp
      "[#{timestamp.utc.iso8601}]" if timestamp
    end

    def make_tweetable message
      message.length > 140 ? "#{message[0, 137]}..." : message
    end
  end
end
