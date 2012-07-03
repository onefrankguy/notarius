require 'notarius/secretary'
require 'notarius/config'
require 'notarius/version'

module Notarius
  @configs = {}

  ##
  # Configure logging for the named module.
  #
  # @yieldparam log [Config]
  #
  # @example
  #   Notarius.configure 'BIG' do |log|
  #     log.console = true
  #     log.file = '/var/log/notarius/big.log'
  #   end

  def self.configure name, &block
    name = namespace name
    @configs[name] = Config.new if @configs[name].nil?
    @configs[name].instance_eval(&block) if block_given?
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
  # Return a config with the given name. Validates the config first.
  # @return [Config, nil] matching config or +nil+ if none found
  # @see Notarius.validate

  def self.config name
    validate name
    @configs[name]
  end

  ##
  # Validate a config with the given name.
  # @param [String] name name of config to validate
  # @raise [RuntimeError] when file is already being logged to

  def self.validate name
    config = @configs[name]
    if config
      @configs.each do |n, c|
        if n != name && c.file && c.file == config.file
          fail "Notarius::#{name} logs to the same file as Notarius::#{n}."
        end
      end
    end
  end
  private_class_method :validate

  ##
  # Convert an +Object+ to a +String+ that can be used as a namespace.
  # This has to generate something that matches Ruby's idea of a
  # constant.
  # @raise [RuntimeError] when +name+ is empty
  # @param [#to_s] name name of the namespace
  # @return [String] converted namespace

  def self.namespace name
    name = name.to_s
    if name.empty?
      fail "namespaces can't be empty"
    end
    name[0, 1].upcase + name[1, name.size]
  end
  private_class_method :namespace
end
