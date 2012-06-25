require 'notarius/formatter'

describe Notarius::Formatter do
  it 'converts whitespace to spaces' do
    formatter = Notarius::Formatter.new

    message = "\tMessage\t\twith\ttabs\t\t"
    message = formatter.call(nil, nil, nil, message) 
    message.should == 'Message with tabs'

    message = "\nMessage\r\rwith\rcarriage\rreturns\r\r"
    message = formatter.call(nil, nil, nil, message) 
    message.should == 'Message with carriage returns'

    message = "\nMessage\n\nwith\nnew\nlines\n\n"
    message = formatter.call(nil, nil, nil, message) 
    message.should == 'Message with new lines'

    message = " Message  with extra spaces  "
    message = formatter.call(nil, nil, nil, message) 
    message.should == 'Message with extra spaces'
  end
end
