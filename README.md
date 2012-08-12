Github Skype Webhook
====================

Post Github commits to a Skype team chat.

Installation
------------

1. Get a Skype developer account: http://developer.skype.com/
It's $5, payable in increments of $10.

2. Download the SkypeKit SDK.

3. Build [libskypekit](https://github.com/railsware/libskypekit).

4. Bundle install to build [skypekit](https://github.com/railsware/skypekit).
I used my [fork](https://github.com/eddroid/skypekit) for my build.

5. Download a [SkypeKit Runtime](http://developer.skype.com/skypekit/development-guide/skype-kit-runtime-versions) for your OS and chipset.
The runtime must be running at the same time in a separate process for the apps to work.

6. Request a Skype development key pair.

6. Run the skypekit gem ping\_pong example app. Use it to get the convo\_id for the team chat you want to post messages to.

7. Config: ./config/config.yml.example -> ./config/config.yml

8. Test with app.rb. Deploy the Sinatra app (service.rb) via config.ru.
 
