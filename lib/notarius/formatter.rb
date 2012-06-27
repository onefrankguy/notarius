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
