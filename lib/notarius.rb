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
  #
  # @example
  #   Notarius.configure 'BIG' do |log|
  #     log.console = true
  #     log.file = '/var/log/notarius/big.log'
  #   end

  def configure name, &block
    name = namespace name
    @configs[name] ||= Config.new
    block.call @configs[name] if block
    return if self.const_defined? name

    mod = Module.new do
      define_method :log do
        @secretary ||= Secretary.new
        @secretary.configure Notarius.config(name)
        @secretary
      end
    end
    self.const_set name, mod
  end

  ##
  # Gets the configuration for a module.
  # @private
  # @param [String] name the module's name
  # @return [Config, nil] the module's configuration or +nil+ if none
  #   was found

  def config name
    validate name
    @configs[name]
  end


  private

  ##
  # Validates a module's configuration.
  # @private
  # @param [String] name the module's name
  # @return [void]
  # @raise [RuntimeError] if the module's file is used by another module

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

  ##
  # Generates a name that can be used for a module.
  # @private
  # @param [#to_s] name the requested name
  # @return [String] the module's name
  # @raise [RuntimeError] if the requested name is empty

  def namespace name
    name = name.to_s
    fail "namespaces can't be empty" if name.empty?
    name[0] = name[0].capitalize
    name
  end
end
