require 'logger'

module Notarius
  @configs = {}

  def self.configure name, &block
    @configs[name] = LogConfig.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?

    mod = Module.new do
      define_method :log do
        if @secreatry.nil?
          @secretary = Secretary.new
          @secretary << Notarius.config(name).streams
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
    def initialize
      @loggers = []
    end

    def << *streams
      streams.flatten!
      streams.each do |stream|
        logger = Logger.new stream
        logger.level = Logger::INFO
        @loggers << logger
      end
    end

    def info message
      @loggers.each { |l| l.info message }
    end
  end

  class LogConfig 
    attr_reader :streams

    def initialize
      @streams = []
    end

    def console= val
      tee $stdout if val
    end

    def file= path
      tee path
    end

    def tee stream
      @streams << stream
    end
  end
end
