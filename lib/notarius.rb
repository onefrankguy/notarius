require 'logger'

module Notarius
  def self.configure name, &block
    config = LogConfig.new
    config.instance_eval(&block) if block_given?
    mod = Module.new do
      @@log = Logger.new(config.file.path)
      @@log.level = Logger::INFO
      def log
        @@log
      end
    end
    if self.const_defined? name
      self.const_get(name).extend mod
    else
      self.const_set name, mod
    end
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
