require 'notarius/secretary'
require 'stringio'

describe Notarius::Secretary do
  it 'can log info messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.info 'info message'
    logger.string.should end_with("info message\n")
    logger.string.should start_with('INFO')
  end

  it 'can log warning messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.warn 'warning message'
    logger.string.should end_with("warning message\n")
    logger.string.should start_with('WARN')
  end

  it 'can log error messages' do
    logger = StringIO.new
    secretary = Notarius::Secretary.new
    secretary.add 'logger', logger
    secretary.error 'error message'
    logger.string.should end_with("error message\n")
    logger.string.should start_with('ERROR')
  end
end
