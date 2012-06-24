require 'notarius'

describe Notarius do
  before :each do
    Dir['*.log'].each { |log| FileUtils.rm log }
  end

  it 'creates a namespace when configured' do
    Notarius.configure 'BIG'
    Notarius::BIG.class.should == Module
  end

  it 'can log to a file' do
    Notarius.configure('BIG') { |l| l.file.path = 'player.log' }
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
    Notarius.configure('BIG') { |l| l.file.path = 'player.log' }
    player = Class.new do
      include Notarius::BIG
      def initialize 
        log.info 'New player created!'
      end
    end
    player.new
    File.read('player.log').should include('New player created!')

    Notarius.configure('BIG') { |l| l.file.path = 'monster.log' }
    monster = Class.new do
      include Notarius::BIG
      def initialize 
        log.info 'New monster created!'
      end
    end
    monster.new
    File.read('monster.log').should include('New monster created!')
  end

  it 'should allow for unique namespaces' do
    Notarius.configure('Player') { |l| l.file.path = 'player.log' }
    player = Class.new do 
      include Notarius::Player
      def initialize
        log.info 'New player created!'
      end
    end

    Notarius.configure('Monster') { |l| l.file.path = 'monster.log' }
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
