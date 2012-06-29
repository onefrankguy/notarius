require 'notarius/secretary'
require 'stringio'

describe Notarius::TempSecretary do
  describe 'logging' do
    let(:logger) { StringIO.new }
    let(:secretary) do
      c = Notarius::Config.new
      c.file = logger
      s = Notarius::TempSecretary.new
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
  end

  describe 'configure' do
    it 'logs to multiple outputs' do
      secretary = Notarius::TempSecretary.new

      io1 = Notarius::Config.new
      io1.file = StringIO.new
      secretary.configure io1 

      io2 = Notarius::Config.new
      io2.file = StringIO.new
      secretary.configure io2 

      secretary.info 'info message'
      io1.file.string.should match(/^INFO \[[^\]]+\] info message\n$/)
      io2.file.string.should match(/^INFO \[[^\]]+\] info message\n$/)
    end
  end
end
