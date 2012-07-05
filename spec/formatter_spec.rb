require 'notarius/formatter'

describe Notarius::Formatter do
  describe '#call' do
    let(:formatter) { Notarius::Formatter.new }

    it 'allows all arguments to be nil' do
      message = formatter.call(nil, nil, nil, nil)
      message.should == "\n"
    end

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

    it 'removes extra whitespace from severity' do
      message = formatter.call("\swarn\s", nil, nil, nil)
      message.should == "WARN\n"
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
      message.should have_at_least(141).characters
      message = formatter.call('INFO', nil, nil, message)
      message.strip.should have(140).characters
    end

    it 'makes exceptions tweetable' do
      message = <<-EOF
      This is a really, really long message that needs to
      be more than 140 characters so that Notarius can trim it
      down to something more reasonable in length.
      EOF
      message.should have_at_least(141).characters

      backtrace = <<-EOF
      This is a really, really long backtrace that needs to
      be more than 140 characters so that Notarius can trim it
      down to something more reasonable in length.
      EOF
      backtrace.should have_at_least(141).characters

      exception = Exception.new(message)
      exception.set_backtrace [backtrace]
      lines = formatter.call('INFO', nil, nil, exception).split("\n")
      lines.each { |line| line.should have(140).characters }
    end

    it 'formats messages as "LEVEL [timestamp] message\n"' do
      timestamp = Time.parse('2012-06-25 21:17:44 -0400')
      message = formatter.call('level', timestamp, nil, 'message')
      message.should == "LEVEL [2012-06-26T01:17:44Z] message\n"
    end

    it 'appends newlines to messages' do
      message = formatter.call(nil, nil, nil, 'message')
      message.should == "message\n"
    end

    it 'formats exceptions nicely' do
      exception = Exception.new('message')
      exception.set_backtrace ['trace this line', 'back to here']
      lines = formatter.call(nil, nil, nil, exception).split("\n")
      results = ['message', '! trace this line', '! back to here']
      lines.should == results
    end

    it 'formats objects nicely' do
      object = Class.new do
        def inspect
          'details'
        end
      end
      message = formatter.call(nil, nil, nil, object.new)
      message.should == "details\n"
    end

    it 'formats exceptions without backtraces nicely' do
      exception = Exception.new('message')
      message = formatter.call(nil, nil, nil, exception)
      message.should == "message\n"
    end

    it 'formats objects that look like exceptions nicely' do
      exception = Class.new do
        def message
          message = Class.new do
            def inspect
              'message'
            end
          end
          message.new
        end

        def backtrace
          backtrace = Class.new do
            def inspect
              'backtrace'
            end
          end
          backtrace.new
        end
      end
      lines = formatter.call(nil, nil, nil, exception.new).split("\n")
      results = ['message', '! backtrace']
      lines.should == results
    end
  end
end
