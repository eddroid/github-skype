require 'skypekit'

trap('INT') do
  terminate
end

config = YAML.load(File.read('./config/config.yml'))

puts "initializing..."
puts config['KEY']
$skype = Skypekit::Skype.new(:keyfile => config['KEY'])
puts "initialized."

puts "starting ..."
$skype.start
puts "started"

puts "logging in"
$skype.login(config['USER'], config['PASS'])
puts "logged in"

def terminate
  puts "Terminating..."
  $skype.stop
  exit
end

loop do
  event = $skype.get_event

  unless event
    sleep 5
    next
  end

  puts event.data.inspect

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
end
