pids = "ps ax | grep #{File.basename(__FILE__)} | grep -v grep | grep -v #{Process.pid} | awk '{print $1}'"
if (`#{pids}`.length > 0)
  puts "There can be only one..."
  `#{pids} | xargs kill -9`
  puts "sleeping..."
  sleep 10
end

require 'skypekit'
require 'htmlentities'

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

puts "logging in..."
$skype.login($config['USER'], $config['PASS'])
puts "logged in"

def terminate
  puts "Terminating..."
  $skype.stop
  puts "Terminated"
  exit
end

def skype_event_loop(&block)
  $terminate = false
  $terminate_count = 0
  loop do
    event = $skype.get_event
    unless event

      # At some point in the future the message is "commited" in Skype. "Commit" = appears in my Skype client.
      # If I terminate before then, the message isn't sent.
      # libskypekit and skypekit don't send me any signals when this happens.
      # It seems to happen 30-35 seconds after the message is sent.
      # This loop sleeps 5 seconds, so between the 6th and 7th loop after the message is sent, it appears in my Skype.
      # Wait for 10 empty cycles (50 seconds) before terminating to give Skype enough time to "commit" the message.
      if $terminate
        $terminate_count -= 1
        puts "Countdown: #{$terminate_count}"
        if ($terminate_count <= 0)
          terminate
        end
      end

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

    case event.type
    when :account_status
      if event.data.logged_in?
        puts "sending message to #{$config['CONVO_ID']}"
        puts ARGV.first
        $skype.send_chat_message($config['CONVO_ID'], ARGV.first)
      end
    when :chat_message
      message = HTMLEntities.new.decode(event.data.body)
      if (message == ARGV.first) 
        # confirmed my message is received
        $terminate = true
        $terminate_count = 10
      else 
        # some other message
        puts message
        puts ARGV.first
      end
    end
  end
else
  skype_event_loop do |event|
    puts event.data.inspect
  end
end

