require 'notarius/secretary'
require 'notarius/config'
require 'notarius/exception'

module Notarius
  @configs = {}

  ##
  # Configures logging for the named module. A +Notarius::Config+ object
  # is passed to the block so you can set logging attributes. Eg:
  #
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
  # Validates and returns a config with the given name.

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
