require 'notarius/formatter'

describe Notarius::Formatter do
  describe 'call' do
    it 'converts whitespace to spaces' do
      message = "\sMessage\r\nwith\twhitespace  "
      message = Notarius::Formatter.new.call(nil, nil, nil, message)
      message.should == 'Message with whitespace'
    end
  end
end
