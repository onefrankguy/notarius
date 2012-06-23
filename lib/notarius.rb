module Notarius
  def self.configure name
    self.const_set name, Module.new
  end
end
