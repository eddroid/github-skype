post "/" do
  payload = request.body.read

  return "No payload" if payload.nil?

  logger.info payload 
  logger.info CGI.parse(payload)["payload"][0]
  payload = JSON.parse(CGI.parse(payload)["payload"][0])

  # parse message
  logger.info "Repo: #{payload["repository"]["name"]}"
  head = payload["head_commit"]
  author = head["author"]
  logger.info "Author: #{author["name"]} <#{author["email"]}>"
  logger.info "Message: #{head["message"]}"
  logger.info "URL: #{head["url"]}"

  message = "\"#{head['message']}\" by #{author['name']} <#{author['email']}> [#{head['url']}]"
  logger.info message

  # deploy-hook
  logger.info `bundle exec ruby send_skype_message.rb \"#{message.gsub!('"', '\"')}\"`
  200
end

get "/" do
  status 405
  headers "Allow" => "POST"
  body "The method specified in the Request-Line is not allowed for the resource identified by the Request-URI."
end
