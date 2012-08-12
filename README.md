Github Skype Webhook
====================

Post Github commits to a Skype team chat.

Installation
------------

1. Get a Skype developer account: http://developer.skype.com/  
  * It costs $5 in Skype credit. Skype credit is only available in increments of $10.

2. Download the [SkypeKit SDK](http://developer.skype.com/account/tools).

3. Build [libskypekit](https://github.com/railsware/libskypekit).  
  * It requires the SkypeKit SDK.  
  * It wraps the SDK.

4. Clone this repo.

5. Bundle install to build the [skypekit](https://github.com/railsware/skypekit) gem.  
  * I used my [fork](https://github.com/eddroid/skypekit) for my build.  
  * The skypekit gem requires libskypekit.  

6. Download a [SkypeKit Runtime](http://developer.skype.com/skypekit/development-guide/skype-kit-runtime-versions) for your OS and chipset.  
  * The SkypeKit Runtime is a headless version of Skype.  All requests to Skype's servers are proxied through it.
  * The runtime must be running simultaneously in a separate process for Skype apps to work.

7. Request a Skype development key pair.
  * Gives your app permission to access the Skype server.
  * Development key pairs expire in a few months, but you can always generate another one.

8. Run the skypekit gem's ping\_pong example app. Use it to get the convo\_id for the team chat you want to post messages to.

9. Generate your config: ./config/config.yml.example -> ./config/config.yml

10. Test with app.rb. Deploy the Sinatra app (service.rb) via config.ru.
