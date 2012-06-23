module Notarius
  def self.configure name
    self.const_set name, nil
  end
end
