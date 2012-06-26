require 'time'

module Notarius
  class Formatter
    # This is the interface Ruby's Logger class expects.
    def call severity, timestamp, application, message
      result = []
      result << format_severity(severity) if severity
      result << '[' + format_timestamp(timestamp) + ']' if timestamp
      result << remove_whitespace(message) if message
      make_tweetable(result.join(' ')) + "\n"
    end

    def format_severity severity
      severity.strip.upcase
    end
    private :format_severity

    def remove_whitespace message
      message.gsub(/[\t\r\n\s]+/, ' ').strip
    end
    private :remove_whitespace

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
