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
    Notarius.configure 'BIG' do |l|
      l.file.path = 'player.log'
    end
    class Player
      include Notarius::BIG
      def initialize
        log.info 'New player created!'
      end
    end
    Player.new
    File.read('player.log').should include('New player created!')
  end

  it 'allows namespaces to be overwritten' do
    Notarius.configure 'BIG' do |l|
      l.file.path = 'player.log'
    end
    class Player
      include Notarius::BIG
      def initialize
        log.info 'New player created!'
      end
    end
    Player.new
    File.read('player.log').should include('New player created!')

    Notarius.configure 'BIG' do |l|
      l.file.path = 'monster.log'
    end
    class Monster 
      include Notarius::BIG
      def initialize
        log.info 'New monster created!'
      end
    end
    Monster.new
    File.read('monster.log').should include('New monster created!')
  end
end 
