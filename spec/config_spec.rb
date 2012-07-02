require 'notarius/config'

describe Notarius::Config do
  let(:config) { Notarius::Config.new }

  it 'defaults to no console' do
    config.console.should be_false
  end

  it 'defaults to no file' do
    config.file.should be_false
  end

  it 'lets you configure a console' do
    config.should respond_to(:console=)
  end

  it 'lets you configure a file' do
    config.should respond_to(:file=)
  end
end
