require 'notarius'
require 'stringio'

describe Notarius do
  before :each do
    Dir['*.log'].each { |log| FileUtils.rm log }
    Notarius.instance_variable_set :@configs, {}
  end

  it 'creates a namespace when configured' do
    Notarius.configure 'BIG'
    Notarius::BIG.class.should == Module
  end

  it 'can log to STDOUT' do
    Notarius.configure('BIG') { |l| l.console = true }
    player = Class.new do
      include Notarius::BIG
      def initialize io
        @log = Logger.new(io)
        log.info 'New player created!'
      end
    end
    output = StringIO.new
    player.new output
    output.seek 0
    output.read.should include('New player created!')
  end

  it 'can log to a file' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }
    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info 'New player created!'
      end
    end
    player.new
    File.read('player.log').should include('New player created!')
  end

  it 'allows namespaces to be overwritten' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }
    player = Class.new do
      include Notarius::BIG
      def initialize 
        log.info 'New player created!'
      end
    end
    player.new
    File.read('player.log').should include('New player created!')

    Notarius.configure('BIG') { |l| l.file = 'monster.log' }
    player.new
    File.read('monster.log').should include('New player created!')
  end

  it 'should allow for unique namespaces' do
    Notarius.configure('Player') { |l| l.file = 'player.log' }
    player = Class.new do 
      include Notarius::Player
      def initialize
        log.info 'New player created!'
      end
    end

    Notarius.configure('Monster') { |l| l.file = 'monster.log' }
    monster = Class.new do
      include Notarius::Monster
      def initialize
        log.info 'New monster created!'
      end
    end

    monster.new
    player.new
    File.read('monster.log').should_not include('New player created!')
  end
end 
