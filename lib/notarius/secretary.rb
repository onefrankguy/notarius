require 'notarius/formatter'
require 'logger'

module Notarius
  class TempSecretary
    def initialize
      @loggers = {}
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
      @loggers.values.each { |l| l.info message }
    end

    def warn message
      @loggers.values.each { |l| l.warn message }
    end

    def error message
      @loggers.values.each { |l| l.error message }
    end

    def add key, stream
      @loggers[key] = Logger.new stream
      @loggers[key].formatter = Formatter.new
    end
    private :add

    def delete key
      @loggers.delete(key)
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
