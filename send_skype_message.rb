require 'skypekit'

trap('INT') do
  terminate
end

$config = YAML.load(File.read('./config/config.yml'))

# SkypeKit Runtime must be running concurrently
runtime = fork do
  exec $config['SKYPEKIT_BINARY'] 
end
Process.detach(runtime)

puts "initializing..."
$skype = Skypekit::Skype.new(:keyfile => $config['KEY'])
puts "initialized."

puts "starting ..."
$skype.start
puts "started"

puts "logging in"
puts $skype.login($config['USER'], $config['PASS'])
puts "logged in"

def terminate
  puts "Terminating..."
  $skype.stop
  exit
end

def skype_event_loop(&block)
  loop do
    event = $skype.get_event
    unless event
      sleep 5
      next
    end

    case event.type

    when :account_status
      if event.data.logged_in?
        puts "Congrats! We are Logged in!"
      end

      if event.data.logged_out?
        puts "Authentication failed: #{event.data.reason}"
        terminate
      end
    end
    
    yield event

  end # /loop
end # /def skype_event_loop

# main
if (ARGV.first) 
  skype_event_loop do |event|
    puts event.data.inspect
    if event.data.logged_in?
      puts "sending message to #{$config['CONVO_ID']}"
      puts ARGV.first
      puts $skype.send_chat_message($config['CONVO_ID'], ARGV.first)
      terminate
    end
  end
else
  skype_event_loop do |event|
    puts event.data.inspect
  end
end

