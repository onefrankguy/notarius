module Notarius
  ##
  # Holds configuration information for a logging namespace.

  class Config
    ##
    # Turn console logging on or off. Default is off.
    # @return [Boolean] whether console logging is enabled
    attr_accessor :console

    ##
    # Turn file logging on or off. Default is off.
    # @return [String, nil] path to the file, +nil+ if off
    attr_accessor :file
  end
end
