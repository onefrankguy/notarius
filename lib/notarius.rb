require 'notarius/secretary'
require 'notarius/config'
require 'notarius/exception'

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

  ##
  # Validate and return a config with the given name.
  # @raise [Exception] configured file is already being logged to
  # @return [Config, nil] matching config or +nil+ if none found

  def self.config name
    config = @configs[name]
    if config
      @configs.each do |n, c|
        if n != name && c.file && c.file == config.file
          message = <<EOF
Notarius::#{name} logs to the same file as Notarius::#{n}.
EOF
          raise Notarius::Exception.new message
        end
      end
    end
    config
  end
end
