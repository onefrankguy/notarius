require 'notarius/formatter'
require 'logger'

module Notarius
  class Secretary
    ##
    # Create a new instance of Secretary.
    # @return [Secretary]

    def initialize
      @loggers = {}
      @messages = {}
    end

    ##
    # Configure a Secretary.
    # @param [Config] config the configuration for this Secretary

    def configure config
      if config.console
        add :console, logger(config.console, $stdout)
      else
        delete :console
      end
      if config.file
        add :file, config.file
      else
        delete :file
      end
    end

    ##
    # Log an informative message. Informative messages show up the log
    # with "INFO" at the start of the line.

    def info message
      log Logger::INFO, message
    end

    ##
    # Log a warning message. Warning messages show up in the log with
    # "WARN" at the start of the line.

    def warn message
      log Logger::WARN, message
    end

    ##
    # Log an error message. Error messages show up in the log with
    # "ERROR" at the start of the line.

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
      stream.respond_to?(:write) && stream.respond_to?(:close)
    end
  end
end
