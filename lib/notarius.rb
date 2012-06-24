require 'logger'

module Notarius
  @configs = {}

  def self.configure name, &block
    @configs[name] = Config.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?

    mod = Module.new do
      define_method :log do
        @secretary = Secretary.new if @secretary.nil?
        @secretary.configure Notarius.config(name)
        @secretary
      end
    end

    if self.const_defined? name
      self.const_get(name).extend mod
    else
      self.const_set name, mod
    end
  end

  def self.config name
    @configs[name]
  end

  class Secretary
    def initialize
      @loggers = {}
    end

    def configure config
      if !config.console
        delete(:console)
      else
        add(:console, $stdout)
      end

      if !config.file
        delete(config.file)
      else
        add(config.file, config.file)
      end
    end

    def info message
      @loggers.values.each { |l| l.info message }
    end

    def add key, stream
      unless @loggers.has_key? key
        logger = Logger.new stream
        logger.level = Logger::INFO
        @loggers[key] = logger
      end
    end

    def delete key
      logger = @loggers.delete(key)
      logger.close rescue nil
    end
  end

  class Config
    attr_accessor :console
    attr_accessor :file
  end
end
