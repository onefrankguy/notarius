require 'notarius/secretary'
require 'stringio'

describe Notarius::Secretary do
  def match_message level, message
    match(/^#{level.upcase} \[[^\]]+\] #{message}\n$/)
  end

  describe 'logging' do
    let(:logger) { StringIO.new }
    let(:secretary) do
      c = Notarius::Config.new
      c.file = logger
      s = Notarius::Secretary.new
      s.configure c
      s
    end

    before :each do
      logger.truncate 0
      logger.rewind
    end

    %w{info warn error}.each do |level|
      it "can log #{level} messages" do
        message = "#{level} message"
        secretary.send(level.to_sym, message)
        logger.string.should match_message(level, message)
      end
    end
  end

  describe '#configure' do
    it 'logs to multiple outputs' do
      io1 = StringIO.new
      io2 = StringIO.new

      secretary = Notarius::Secretary.new

      config = Notarius::Config.new
      config.console = io1
      config.file = io2 
      secretary.configure config

      secretary.info 'info message'
      io1.string.should match_message(:INFO, 'info message')
      io2.string.should match_message(:INFO, 'info message')
    end

    it 'defaults console to stdout' do
      config = Notarius::Config.new
      config.console = true
      secretary = Notarius::Secretary.new

      output = StringIO.new
      stdout = $stdout
      begin
        $stdout = output
        secretary.configure config
        secretary.info 'message'
      ensure
        $stdout = stdout 
      end

      output.string.should match_message(:INFO, 'message')
    end

    it 'removes a logger when no longer referenced' do
      io1 = StringIO.new
      io2 = StringIO.new

      config1 = Notarius::Config.new
      config1.console = io1
      config1.file = io2

      secretary = Notarius::Secretary.new
      secretary.configure config1
      secretary.info 'noodles'
      io1.string.should match_message(:INFO, 'noodles')
      io2.string.should match_message(:INFO, 'noodles')

      secretary.configure Notarius::Config.new 
      secretary.info 'pasta'
      io1.string.should_not match_message(:INFO, 'pasta')
      io2.string.should_not match_message(:INFO, 'pasta')
    end

    it 'closes a logger when it removes it' do
      config = Notarius::Config.new
      config.console = StringIO.new 

      secretary = Notarius::Secretary.new
      secretary.configure config
      secretary.info 'noodles'
      config.console.string.should match_message(:INFO, 'noodles')

      secretary.configure Notarius::Config.new 
      secretary.info 'pasta'
      config.console.should be_closed
    end
  end

  it 'skips duplicate messages per logger' do
      io1 = StringIO.new
      io2 = StringIO.new

      secretary = Notarius::Secretary.new

      config1 = Notarius::Config.new
      config1.console = io1
      secretary.configure config1

      secretary.error 'same message'

      config2 = Notarius::Config.new
      config2.console = io1
      config2.file = io2
      secretary.configure config2

      secretary.info 'same message'

      io1.string.should_not match_message(:INFO, 'same message')
      io2.string.should match_message(:INFO, 'same message')
  end
end
