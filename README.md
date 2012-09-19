Github Skype Webhook
====================

Allows GitHub to post commit messages to a Skype team chat via a webhook.

Setup
-----

### Assumptions
* A 32-bit Amazon AMI OS on EC2.
* Base dir is my home dir: `/home/ec2-user/`

### Steps
1. Get a Skype developer account: http://developer.skype.com/  
  * It costs $5 in Skype credit. Skype credit is only available in increments of $10.

2. Download the [SkypeKit SDK for Desktop](http://developer.skype.com/account/tools).

3. Create a Skype project, generate a keypair, and download it.

Installation
------------

1. Install some libs
```
sudo yum update -y
sudo yum install -y git make gcc-c++ mesa-libGL-devel freeglut-devel
```

1. Amazon didn't have a package for CMake version 2.8.2 or greater. If you don't have it, build it.
```
wget "http://www.cmake.org/files/v2.8/cmake-2.8.9.tar.gz"
tar -zvxf cmake-2.8.9.tar.gz
cd cmake-2.8.9
./bootstrap
make
sudo make install
cmake --version # should return "cmake version 2.8.9"
```

1. Back home: `cd ..`

1. Build the SkypeKit SDK
```
tar -zxvf sdp-distro-desktop-skypekit_4.3.1.17_1899690.tar.gz
cd sdp-distro-desktop-skypekit_4.3.1.17_1899690/interfaces/skype/cpp_embedded/
./BuildWithCmake.sh
```

1. Back home: `cd ../../../../`

1. Build [libskypekit](https://github.com/railsware/libskypekit)
```
git clone https://github.com/railsware/libskypekit.git
cd libskypekit
DEBUG=1 SKYPEKIT_SDK=~/sdp-distro-desktop-skypekit_4.3.1.17_1899690/ ./build.sh
sudo ./install.sh
sudo ln -s /usr/local/lib/libskypekit.so /usr/lib/libskypekit.so
```
If you get an error saying "recompile with -fPIC", read the libskypekit docs. You should delete the SDK directory and start again. You are using a 32-bit OS, right?

1. Back home: `cd ..`

1. Build this app
```
git clone https://github.com/eddroid/github-skype.git
cd github-skype
sudo yum install -y rubygems ruby-devel libffi-devel
sudo gem install bundler --no-rdoc --no-ri
bundle
```

1. Back home: `cd ..`

1. In a separate window start the Skype runtime. The runtime must be running at the same time as the app.
```
cd sdp-distro-desktop-skypekit_4.3.1.17_1899690/bin/linux-x86
./linux-x86-skypekit-novideo
```

1.  Back home: `cd ..`

1. Configure this app
```
cd github-skype/
cp config/config.yml.example config/config.yml
```
Edit config.yml. Skip the convo_id for now. Did you remember to get your keypair from the Skype developer site?

1. Start the test app: `bundle exec ruby send_skype_message.rb`
You'll see lots of output text. Look for "Congrats! We are Logged in!" to confirm that you were able to login successfully.

1. Send yourself (or have a friend send you) a Skype message in the team chat room. You'll see output that looks like this:
```
<Skypekit::FFI::ChatMessageData:0xb6e59528> convo_id=#XXXX convo_guid=#XXXX author=XXX author_displayname=XXX sent_at=Wed Aug XX 00:39:53 +0000 2012 body=message
```
Get the convo_id from this output.

1. Ctrl-C the app. Note that the Skype runtime dies with it.

1. Deploy the Sinatra app using `config.ru`. That's beyond the scope of these docs.

1. Setup a Github webhook integration for your repo pointing to your github-skype server. Also beyond scope.
