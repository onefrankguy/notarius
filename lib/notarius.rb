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
        logger = @loggers.delete(:console)
        logger.close unless logger.nil?
      elsif !@loggers.has_key?(:console)
        logger = Logger.new($stdout)
        logger.level = Logger::INFO
        @loggers[:console] = logger
      end

      if !config.file
        logger = @loggers.delete(config.file)
        logger.close unless logger.nil?
      elsif !@loggers.has_key?(config.file)
        logger = Logger.new(config.file)
        logger.level = Logger::INFO
        @loggers[config.file] = logger
      end
    end

    def info message
      @loggers.values.each { |l| l.info message }
    end
  end

  class Config
    attr_accessor :console
    attr_accessor :file
  end
end
