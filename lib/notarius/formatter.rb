require 'time'

module Notarius
  class Formatter
    # This is the interface Ruby's Logger class expects.
    def call severity, timestamp, application, message
      result = []
      result << severity if severity
      result << '[' + format_timestamp(timestamp) + ']' if timestamp
      result << remove_whitespace(message) if message
      result.join(' ')
    end

    def remove_whitespace message
      message.gsub!(/[\t\r\n\s]+/, ' ').strip
    end
    private :remove_whitespace

    def format_timestamp timestamp 
      timestamp.utc.iso8601
    end
    private :format_timestamp
  end
end
