require 'notarius'

describe Notarius do
  it 'creates a namespace when configured' do
    Notarius.configure 'BIG'
    Notarius::BIG.class.should == Module
  end
end 
