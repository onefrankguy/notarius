require 'notarius'
require 'stringio'

describe Notarius do
  before :each do
    Dir['*.log'].each { |log| FileUtils.rm log }
    Notarius.instance_variable_set :@configs, {}
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

  it 'logs levels in the message' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info 'This is information.'
        log.warn 'This is a warning.'
        log.error 'This is an error.'
      end
    end
    player.new

    lines = File.read('player.log').split("\n")
    lines[0].should match('^INFO')
    lines[1].should match('^WARN')
    lines[2].should match('^ERROR')
  end

  it 'formats timestamps as ISO 8601' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info 'New player created!'
      end
    end

    start = Time.now.utc
    player.new

    lines = File.read('player.log').split("\n")
    stamp = lines.first.match(/\[([^\]]+)/)[1]
    ((start - 1)..(start + 1)).should cover(Time.parse(stamp))
  end

  it 'converts whitespace to spaces' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        log.info "Message\twith\ttabs"
        log.info "Message\rwith\rcarriage\rreturns"
        log.info "Message\nwith\nnewlines"
        log.info '   Message with extra spaces '
      end
    end
    player.new

    lines = File.read('player.log').split("\n")
    lines[0].should include('Message with tabs')
    lines[1].should include('Message with carriage returns')
    lines[2].should include('Message with newlines')
    lines[3].should end_with('] Message with extra spaces')
  end

  it 'makes logs tweetable' do
    Notarius.configure('BIG') { |l| l.file = 'player.log' }

    player = Class.new do
      include Notarius::BIG
      def initialize
        message = <<-EOF
        This is a really, really long message that needs to
        be more than 140 characters so that Notarius can trim it
        down to something more reasonable in length.
        EOF
        message.length.should > 140 
        log.info message
      end
    end
    player.new

    lines = File.read('player.log').split("\n")
    lines.first.length.should == 140
  end

  it 'can extend existing modules' do
    module Notarius::Noodles
    end
    Notarius.configure('Noodles') { |l| l.console = true }
    Notarius::Noodles.should respond_to(:log)
  end
end 
