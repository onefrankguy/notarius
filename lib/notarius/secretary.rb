require 'notarius/formatter'
require 'logger'

module Notarius
  class Secretary
    def initialize
      @loggers = {}
      @last_message = nil
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
      if message != @last_message
        @loggers.values.each { |l| l.info message }
      end
      @last_message = message
    end

    def warn message
      if message != @last_message
        @loggers.values.each { |l| l.warn message }
      end
      @last_message = message
    end

    def error message
      if message != @last_message
        @loggers.values.each { |l| l.error message }
      end
      @last_message = message
    end

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
