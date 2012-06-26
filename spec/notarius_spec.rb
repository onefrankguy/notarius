require 'notarius'
require 'stringio'

describe Notarius do
  before :each do
    Dir['*.log'].each { |log| FileUtils.rm log }
    Notarius.instance_variable_set :@configs, {}
  end

  after :all do
    Dir['*.log'].each { |log| FileUtils.rm log }
  end

  it 'can log to STDOUT' do
    Notarius.configure('BIG') { |l| l.console = true }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info 'New player created!'
      end
    end

    output = StringIO.new
    begin
      $stdout = output
      player.new
    ensure
      $stdout = STDOUT
    end

    output.string.should include('New player created!')
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
      def run 
        log.info 'Player is running.'
      end
    end
    p = player.new

    p.run
    File.read('player.log').should include('Player is running.')

    Notarius.configure('BIG') { |l| l.file = 'monster.log' }
    p.run
    File.read('monster.log').should include('Player is running.')
  end

  it 'allows for unique namespaces' do
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

  it 'allows info to be logged' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info 'Info!'
      end
    end
    player.new

    File.read('player.log').should include('Info!')
  end

  it 'allows warnings to be logged' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.warn 'Warning!'
      end
    end
    player.new

    File.read('player.log').should include('Warning!')
  end

  it 'allows errors to be logged' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.error 'Error!'
      end
    end
    player.new

    File.read('player.log').should include('Error!')
  end
end 
