require 'notarius/secretary'
require 'stringio'

describe Notarius::Secretary do
  it 'can log info messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.info 'info message'
    logger.string.should match(/^INFO \[[^\]]+\] info message\n$/)
  end

  it 'can log warning messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.warn 'warning message'
    logger.string.should match(/^WARN \[[^\]]+\] warning message\n$/)
  end

  it 'can log error messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.error 'error message'
    logger.string.should match(/^ERROR \[[^\]]+\] error message\n$/)
  end
end
