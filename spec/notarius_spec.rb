require 'notarius'

describe Notarius do
  it 'creates a namespace when configured' do
    Notarius.configure 'BIG'
    Notarius::BIG.class.should == Module
  end

  it 'can log to a file' do
    FileUtils.rm 'player.log' if File.exists? 'player.log'
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
    FileUtils.rm 'player.log' if File.exists? 'player.log'
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

    FileUtils.rm 'monster.log' if File.exists? 'monster.log'
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
