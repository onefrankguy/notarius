require 'notarius/secretary'
require 'stringio'

describe Notarius::Secretary do
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

    it 'can log info messages' do
      secretary.info 'info message'
      logger.string.should match(/^INFO \[[^\]]+\] info message\n$/)
    end

    it 'can log warning messages' do
      secretary.warn 'warning message'
      logger.string.should match(/^WARN \[[^\]]+\] warning message\n$/)
    end

    it 'can log error messages' do
      secretary.error 'error message'
      logger.string.should match(/^ERROR \[[^\]]+\] error message\n$/)
    end

    it 'skips duplicate messages' do
      secretary.error 'same message'
      secretary.info 'same message'
      logger.string.should_not match(/^INFO \[[^\]]+\] same message\n$/)
    end
  end

  describe 'configure' do
    it 'logs to multiple outputs' do
      io1 = StringIO.new
      io2 = StringIO.new

      secretary = Notarius::Secretary.new

      config = Notarius::Config.new
      config.console = io1
      config.file = io2 
      secretary.configure config

      secretary.info 'info message'
      io1.string.should match(/^INFO \[[^\]]+\] info message\n$/)
      io2.string.should match(/^INFO \[[^\]]+\] info message\n$/)
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

      output.string.should match(/^INFO \[[^\]]+\] message\n$/)
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
      io1.string.should match(/^INFO \[[^\]]+\] noodles\n$/)
      io2.string.should match(/^INFO \[[^\]]+\] noodles\n$/)

      secretary.configure Notarius::Config.new 
      secretary.info 'pasta'
      io1.string.should_not match(/^INFO \[[^\]]+\] pasta\n$/)
      io2.string.should_not match(/^INFO \[[^\]]+\] pasta\n$/)
    end

    it 'closes a logger when it removes it' do
      config = Notarius::Config.new
      config.console = StringIO.new 

      secretary = Notarius::Secretary.new
      secretary.configure config
      secretary.info 'noodles'
      config.console.string.should match(/^INFO \[[^\]]+\] noodles\n$/)

      secretary.configure Notarius::Config.new 
      secretary.info 'pasta'
      config.console.should be_closed
    end
  end
end
