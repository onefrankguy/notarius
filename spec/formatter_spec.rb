require 'notarius/formatter'

describe Notarius::Formatter do
  describe 'call' do
    it 'converts whitespace to spaces' do
      message = "\sMessage\r\nwith\twhitespace  "
      message = Notarius::Formatter.new.call(nil, nil, nil, message)
      message.should == 'Message with whitespace'
    end

    it 'formats timestamps as ISO 8601' do
      timestamp = Time.parse('2012-06-25 20:41:30 -0400')
      message = Notarius::Formatter.new.call(nil, timestamp, nil, nil)
      message.should == '[2012-06-26T00:41:30Z]'
    end
  end
end
