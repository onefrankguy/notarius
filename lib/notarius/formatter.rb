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
    # This is the interface Ruby's Logger class expects.
    # @param [String] severity the severity level of the message
    # @param [Date] timestamp the timestamp for the message
    # @param [Object] application unused
    # @param [Object] message responds to +:message+, +:backtrace+, or +:inspect+
    # @return [String] formatted as "SEVERITY [timestamp] message\\n"

    def call severity, timestamp, application, message
      result = []
      result << format_severity(severity) if severity
      result << '[' + format_timestamp(timestamp) + ']' if timestamp
      result << format_message(message) if message
      make_tweetable(result.join(' ')) + "\n"
    end

    def format_severity severity
      severity.strip.upcase
    end
    private :format_severity

    def format_message message 
      result = []
      if message.respond_to?(:message)
        result << message.message
      else
        result << message
      end
      if message.respond_to?(:backtrace)
        backtrace = [message.backtrace]
        backtrace.flatten!
        backtrace.compact!
        result << backtrace.map { |line| "! %s" % clean_message(line) }
      end
      result.flatten!
      result.map! { |line| clean_message(line) }
      result.join("\n")
    end
    private :format_message

    def clean_message message
      message = message.inspect unless message.kind_of?(String)
      message.gsub(/[\t\r\n\s]+/, ' ').strip
    end
    private :clean_message

    def format_timestamp timestamp 
      timestamp.utc.iso8601
    end
    private :format_timestamp

    def make_tweetable message
      message.length > 140 ? message[0, 137] + '...' : message
    end
    private :make_tweetable
  end
end
