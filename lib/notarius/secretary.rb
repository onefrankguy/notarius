require 'notarius/formatter'
require 'logger'

module Notarius
  ##
  # Provides an API for logging modules.

  class Secretary
    ##
    # Creates a new instance of a Secretary.
    # @return [Secretary]

    def initialize
      @loggers = {}
      @messages = {}
    end

    ##
    # Configures a Secretary.
    # @param [Config] config the configuration
    # @return [void]

    def configure config
      update :console, config.console, $stdout
      update :file, config.file
    end

    ##
    # Logs an informative message. Informative messages show up the log
    # with "INFO" at the start of the line.
    # @param [String, #message, #backtrace, #inspect] message
    # @return [void]

    def info message
      log Logger::INFO, message
    end

    ##
    # Logs a warning message. Warning messages show up in the log with
    # "WARN" at the start of the line.
    # @param [String, #message, #backtrace, #inspect] message
    # @return [void]

    def warn message
      log Logger::WARN, message
    end

    ##
    # Logs an error message. Error messages show up in the log with
    # "ERROR" at the start of the line.
    # @param [String, #message, #backtrace, #inspect] message
    # @return [void]

    def error message
      log Logger::ERROR, message
    end


    private

    def log severity, message
      @loggers.each do |key, logger|
        if message != @messages[key]
          @messages[key] = message
          logger.add(severity) { message }
        end
      end
    end

    def update key, stream, default = nil
      if stream
        add key, logger(stream, default)
      else
        delete key
      end
    end

    def add key, stream
      @loggers[key] = Logger.new stream
      @loggers[key].formatter = Formatter.new
    end

    def delete key
      logger = @loggers.delete(key)
      logger.close unless logger.nil?
    end

    def logger *args
      args.find { |arg| loggable?(arg) }
    end

    def loggable? stream
      io = stream.respond_to?(:write) && stream.respond_to?(:close)
      io || stream.kind_of?(String)
    end
  end
end
