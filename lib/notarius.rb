require 'logger'

module Notarius
  @configs = {}

  def self.configure name, &block
    @configs[name] = Config.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?

    mod = Module.new do
      define_method :log do
        if @secreatry.nil?
          @secretary = Secretary.new(Notarius.config(name))
        end
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
    def initialize config
      @loggers = []
      @loggers << Logger.new($stdout) if config.console
      @loggers << Logger.new(config.file) if config.file
      @loggers.each { |logger| logger.level = Logger::INFO }
    end

    def info message
      @loggers.each { |l| l.info message }
    end
  end

  class Config 
    attr_accessor :console
    attr_accessor :file
  end
end
