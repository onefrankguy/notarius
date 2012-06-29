require 'notarius/formatter'
require 'logger'

module Notarius
  class TempSecretary
    def initialize
      @loggers = {}
    end

    def configure config
      add 'logger', config.file
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
  end
end
