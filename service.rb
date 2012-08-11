configure do
  require 'skypekit'
  config = YAML.load(File.read('./config/config.yml'))

  puts "initializing..."
  puts config['KEY']
  $skype = Skypekit::Skype.new(:keyfile => config['KEY'])
  puts "initialized."

  puts "starting..."
  $skype.start
  puts "started"

  puts "logging in..."
  $skype.login(config['USER'], config['PASS'])
  puts "logged in"

  set :convo_id, config['CONVO_ID']
end

at_exit do
  puts "Terminating..."
  $skype.stop
  exit
end

post "/" do
  payload = request.body.read

  return "No payload" if payload.nil?

  logger.info payload 
  logger.info CGI.parse(payload)["payload"][0]
  payload = JSON.parse(CGI.parse(payload)["payload"][0])

  # message hook
  logger.info "Repo: #{payload["repository"]["name"]}"
  head = payload["head_commit"]
  author = head["author"]
  logger.info "Author: #{author["name"]} <#{author["email"]}>"
  logger.info "Message: #{head["message"]}"
  logger.info "URL: #{head["url"]}"

  message = "\"#{head['message']}\" by #{author['name']} <#{author['email']}> [#{head['url']}]"
  logger.info message

  # deploy-hook
  logger.info settings.convo_id
  $skype.send_chat_message(settings.convo_id, message)

  200
end

get "/" do
  status 405
  headers "Allow" => "POST"
  body "The method specified in the Request-Line is not allowed for the resource identified by the Request-URI."
end
