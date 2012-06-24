require 'logger'

module Notarius
  @configs = {}

  def self.configure name, &block
    @configs[name] = LogConfig.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?

    mod = Module.new do
      define_method :log do
        if @log.nil?
          config = Notarius.config(name)
          @log = Logger.new(config.file.path)
          @log.level = Logger::INFO
        end
        @log
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

  class LogConfig 
    attr_accessor :file
    def initialize
      @file = FileConfig.new
    end
  end

  class FileConfig
    attr_accessor :path
  end
end
