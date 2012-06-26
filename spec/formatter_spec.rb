require 'notarius/formatter'

describe Notarius::Formatter do
  describe 'call' do
    let(:formatter) { Notarius::Formatter.new }

    it 'converts whitespace to spaces' do
      message = "\sMessage\r\nwith\twhitespace  "
      message = formatter.call(nil, nil, nil, message)
      message.should == "Message with whitespace\n"
    end

    it 'formats timestamps as ISO 8601' do
      timestamp = Time.parse('2012-06-25 20:41:30 -0400')
      message = formatter.call(nil, timestamp, nil, nil)
      message.should == "[2012-06-26T00:41:30Z]\n"
    end

    it 'makes severity all upper case' do
      message = formatter.call('info', nil, nil, nil)
      message.should == "INFO\n"
    end

    it 'ignores program name field' do
      message = formatter.call(nil, nil, 'noodles', nil)
      message.should == "\n"
    end

    it 'makes messages tweetable' do
      message = <<-EOF
      This is a really, really long message that needs to
      be more than 140 characters so that Notarius can trim it
      down to something more reasonable in length.
      EOF
      message.length.should > 140
      message = formatter.call(nil, nil, nil, message)
      message.length.should == 141
    end

    it 'formats messages as "level [timestamp] message"' do
      timestamp = Time.parse('2012-06-25 21:17:44 -0400')
      message = formatter.call('LEVEL', timestamp, nil, 'message')
      message.should == "LEVEL [2012-06-26T01:17:44Z] message\n"
    end

    it 'ends messages with newlines' do
      message = formatter.call(nil, nil, nil, nil)
      message.should == "\n"
    end
  end
end
