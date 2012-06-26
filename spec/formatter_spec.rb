require 'notarius/formatter'

describe Notarius::Formatter do
  describe 'call' do
    let(:formatter) { Notarius::Formatter.new }

    it 'converts whitespace to spaces' do
      message = "\sMessage\r\nwith\twhitespace  "
      message = formatter.call(nil, nil, nil, message)
      message.should == 'Message with whitespace'
    end

    it 'formats timestamps as ISO 8601' do
      timestamp = Time.parse('2012-06-25 20:41:30 -0400')
      message = formatter.call(nil, timestamp, nil, nil)
      message.should == '[2012-06-26T00:41:30Z]'
    end

    it 'puts levels at the start of a message' do
      message = formatter.call('INFO', nil, nil, nil)
      message.should == 'INFO'
    end
  end
end
