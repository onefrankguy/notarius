require 'notarius'
require 'tempfile'

describe Notarius do
  def tempfiles *prefixes
    files = prefixes.map { |prefix| Tempfile.new prefix }
    begin
      paths = files.map { |file| file.path }
      paths = paths.first if paths.size == 1
      yield paths if block_given?
    ensure
      files.each { |file| file.close! }
    end
  end

  it 'has a semantic version number' do
    Notarius::VERSION.should match(/^\d+\.\d+\.\d+$/)
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
      lines = File.read(player_log).split("\n")
      lines[0].should end_with('New player created!')
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
      lines = File.read(player_log).split("\n")
      lines[0].should end_with('Player is running.')

      Notarius.configure('BIG') { |l| l.file = monster_log }
      p.run 'Player is still running.'
      lines = File.read(monster_log).split("\n")
      lines[0].should end_with('Player is still running.')
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

  it 'throws an error if separate namespaces log to the same file' do
    tempfiles 'log' do |log|
      Notarius.configure('Player') { |l| l.file = log }
      Notarius.configure('Monster') { |l| l.file = log }

      monster = Class.new do
        include Notarius::Monster
        def initialize
          log.info 'New monster created!'
        end
      end

      expect { monster.new }.to raise_error(RuntimeError)
    end
  end

  describe '#configure' do
    it 'handles lowercase namespaces gracefully' do
      Notarius.configure 'little'
      Notarius.const_defined?(:Little).should be_true
    end

    it 'throws an error if a namespace is empty' do
      expect { Notarius.configure '' }.to raise_error(RuntimeError)
    end

    it 'throws an error if a namespace is nil' do
      expect { Notarius.configure nil }.to raise_error(RuntimeError)
    end

    it 'only checks for namespaces in itself' do
      Object.const_set :Notari, 0
      Notarius.configure :Notari
      Notarius.const_defined?(:Notari, false).should be_true
    end
  end
end
