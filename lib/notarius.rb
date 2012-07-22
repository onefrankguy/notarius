require 'notarius/secretary'
require 'notarius/config'
require 'notarius/version'

##
# Notarius is a logging library with opinions.

module Notarius extend self
  @configs = {}

  ##
  # Configures a logging module. If a matching module exists, it will be
  # reconfigured. Otherwise, a new module will be created.
  #
  # @param [#to_s] name the module's name
  # @yieldparam log [Config] the module's configuration
  # @return [void]
  # @raise [RuntimeError] when name is empty or +nil+
  #
  # @example
  #   Notarius.configure 'BIG' do |log|
  #     log.console = true
  #     log.file = '/var/log/notarius/big.log'
  #   end

  def configure name, &block
    name = make_const name
    @configs[name] ||= Config.new
    block.call @configs[name] if block
    return if const_defined? name, false

    mod = Module.new do
      define_method :log do
        @secretary ||= Secretary.new
        @secretary.configure Notarius.config(name)
        @secretary
      end
    end
    const_set name, mod
  end

  ##
  # @private

  def config name
    validate name
    @configs[name]
  end


  private

  def validate name
    config = @configs[name]
    if config && config.file
      @configs.each do |n, c|
        if n != name && c.file == config.file
          fail "Notarius::#{name} logs to the same file as Notarius::#{n}."
        end
      end
    end
  end

  def make_const name
    name = name.to_s
    fail "namespaces can't be empty" if name.empty?
    name[0] = name[0].capitalize
    name
  end
end
