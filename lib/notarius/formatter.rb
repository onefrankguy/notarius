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
      result = []
      result << format_severity(severity) if severity
      result << format_timestamp(timestamp) if timestamp
      result << parse_message(message) if message
      result.compact!
      result.join(' ')
    end

    def format_backtrace message
      trace = []
      trace << message.backtrace if message.respond_to?(:backtrace)
      trace.flatten!
      trace.compact!
      trace.map { |line| "! #{clean_message(line)}" }
    end

    def format_severity severity
      severity.strip.upcase
    end

    def parse_message message
      result = message.respond_to?(:message) ? message.message : message
      clean_message(result)
    end

    def clean_message message
      message = message.inspect unless message.kind_of?(String)
      message.gsub(/\s+/, ' ').strip
    end

    def format_timestamp timestamp
      "[#{timestamp.utc.iso8601}]"
    end

    def make_tweetable message
      message.length > 140 ? "#{message[0, 137]}..." : message
    end
  end
end
