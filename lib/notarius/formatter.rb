require 'time'

module Notarius
  class Formatter
    # This is the interface Ruby's Logger class expects.
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
        backtrace = message.backtrace || []
        result << backtrace.map { |line| '! ' + line }
      end
      result.flatten!
      result.map! { |line| line.kind_of?(String) ? line : line.inspect }
      result.map! { |line| line.gsub(/[\t\r\n\s]+/, ' ').strip }
      result.join("\n")
    end
    private :format_message

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
