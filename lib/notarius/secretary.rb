require 'notarius/formatter'
require 'logger'

module Notarius
  class Secretary
    def initialize
      @loggers = {}
      @messages = {}
    end

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

    def info message
      log Logger::INFO, message
    end

    def warn message
      log Logger::WARN, message
    end

    def error message
      log Logger::ERROR, message
    end

    def log severity, message
      @loggers.each do |key, logger|
        if message != @messages[key]
          @messages[key] = message
          logger.add(severity) { message }
        end
      end
    end
    private :log

    def add key, stream
      @loggers[key] = Logger.new stream
      @loggers[key].formatter = Formatter.new
    end
    private :add

    def delete key
      logger = @loggers.delete(key)
      logger.close rescue nil
    end
    private :delete

    def logger *args
      args.find { |arg| loggable?(arg) }
    end
    private :logger

    def loggable? stream
      stream.respond_to?(:write) && stream.respond_to?(:close)
    end
    private :loggable?
  end
end
