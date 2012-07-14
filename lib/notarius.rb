require 'notarius/secretary'
require 'notarius/config'
require 'notarius/version'

##
# Notarius is a logging library with opinions.

module Notarius
  @configs = {}

  ##
  # Configure a Notarius logging module. If a module with the given
  # name exists, it will be reconfigured. Otherwise, a new one will
  # be created.
  #
  # @param [#to_s] name module's name
  # @yieldparam log [Config] module's configuration
  # @return [void]
  #
  # @example
  #   Notarius.configure 'BIG' do |log|
  #     log.console = true
  #     log.file = '/var/log/notarius/big.log'
  #   end

  def self.configure name, &block
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
  # Find the configuration for a module.
  # @private
  # @param [String] name module's name
  # @return [Config, nil] module's config or +nil+ if none found

  def self.config name
    validate name
    @configs[name]
  end

  ##
  # Validate a module's configuration.
  # @private
  # @param [String] name module's name
  # @return [void]
  # @raise [RuntimeError] if module's file is already being logged to

  def self.validate name
    config = @configs[name]
    if config && config.file
      @configs.each do |n, c|
        if n != name && c.file == config.file
          fail "Notarius::#{name} logs to the same file as Notarius::#{n}."
        end
      end
    end
  end
  private_class_method :validate

  ##
  # Generate a name that can be used for a module.
  # @private
  # @param [#to_s] name requested name
  # @return [String] valid name
  # @raise [RuntimeError] if +name+ is empty

  def self.namespace name
    name = name.to_s
    fail "namespaces can't be empty" if name.empty?
    name[0] = name[0].capitalize
    name
  end
  private_class_method :namespace
end
