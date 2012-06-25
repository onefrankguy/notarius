module Notarius
  class Formatter
    # This is the interface Ruby's Logger class expects.
    def call severity, datetime, application, message
      remove_whitespace(message)
    end

    def remove_whitespace message
      message.gsub!(/[\t\r\n\s]+/, ' ').strip
    end
    private :remove_whitespace
  end
end
