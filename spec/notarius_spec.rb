require 'notarius'
require 'tempfile'

describe Notarius do
  def tempfiles *prefixes 
    files = prefixes.map { |prefix| Tempfile.new prefix }
    begin
      if files.size == 1 
        yield files.first.path if block_given?
      else
        yield files.map { |file| file.path } if block_given?
      end
    ensure
      files.each do |file|
        file.close
        file.unlink
      end
    end
  end

  before :each do
    Notarius.instance_variable_set :@configs, {}
  end

  it 'can log to a file' do
    tempfiles 'player' do |player_log|
      Notarius.configure('BIG') { |l| l.file = player_log }
      player = Class.new do
        include Notarius::BIG
        def initialize
          log.info 'New player created!'
        end
      end
      player.new
      File.read(player_log).should include('New player created!')
    end
  end

  it 'allows namespaces to be overwritten' do
    tempfiles('player', 'monster') do |player_log, monster_log|
      Notarius.configure('BIG') { |l| l.file = player_log }

      player = Class.new do
        include Notarius::BIG
        def run message
          log.info message
        end
      end
      p = player.new

      p.run 'Player is running.'
      File.read(player_log).should include('Player is running.')

      Notarius.configure('BIG') { |l| l.file = monster_log }
      p.run 'Player is still running.'
      File.read(monster_log).should include('Player is still running.')
    end
  end

  it 'allows for unique namespaces' do
    tempfiles('player', 'monster') do |player_log, monster_log|
      Notarius.configure('Player') { |l| l.file = player_log }
      player = Class.new do 
        include Notarius::Player
        def initialize
          log.info 'New player created!'
        end
      end

      Notarius.configure('Monster') { |l| l.file = monster_log }
      monster = Class.new do
        include Notarius::Monster
        def initialize
          log.info 'New monster created!'
        end
      end

      monster.new
      player.new
      File.read(monster_log).should_not include('New player created!')
    end
  end
end 
