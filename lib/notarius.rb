require 'notarius/secretary'
require 'notarius/config'

module Notarius
  @configs = {}

  def self.configure name, &block
    @configs[name] = Config.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?
    return if self.const_defined? name

    mod = Module.new do
      define_method :log do
        @secretary = Secretary.new if @secretary.nil?
        @secretary.configure Notarius.config(name)
        @secretary
      end
    end
    self.const_set name, mod
  end

  def self.config name
    @configs[name]
  end
end
