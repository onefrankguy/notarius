module Notarius
  ##
  # Holds the configuration for a logging module.

  class Config
    ##
    # Turn console logging on or off. Default is off.
    # @return [Boolean] whether console logging is enabled
    attr_accessor :console

    ##
    # Turn file logging on or off. Default is off.
    # @return [String, nil] the path to the file or +nil+ if off
    attr_accessor :file
  end
end
