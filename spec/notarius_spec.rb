require 'notarius'

describe Notarius do
  it 'creates a namespace when configured' do
    Notarius.const_defined?(:BIG).should be_false
    Notarius.configure 'BIG'
    Notarius.const_defined?(:BIG).should be_true
  end
end 
