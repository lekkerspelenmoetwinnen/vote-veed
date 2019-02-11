# vote-veed
## Requirements
- Some knowledge of Ruby or programming is recommended, but not needed
- It doesn't use much of your computers resources, you can just leave it running in the background
- If you have a slow internet connection you might want to up timeout a bit (see below)
## Installation
### Windows (currently the only option)
- Install ruby from https://rubyinstaller.org/
- Make sure ruby is in your PATH
- Open command prompt and type:

  ```gem install faker```
- Clone or download this repo (and extract)
- You can make changes if you want/can, especially look at `self.categories` in veed.rb, change the values to the ones you want to vote for (but don't you dare change the malle makkers)

## Usage
- Open command prompt in the Veed folder
- Run `ruby main.rb`
- Done! At the start you may see `... timed out!` a lot. If you want, you can type `timeout 150` to set the timeout to 150 seconds for a bit, then change it back to 70 when you see the votes coming in

#### Commands:
- `timeout <seconds>` change the timeout of each voting round (the maximum time it will wait for the voting to finish)
- `safety <level>` change the safety_level, see below
- `ip` show the ip of every thread before voting. Can be useful to turn on to make sure tor is working
- `stop` or `exit` make a guess

## Safety level
The lower the safety_level, the higher the chance Veed will recognize your votes as fake.
But the higher the safety level, the longer it takes to vote.
Currently possible values:
1. Will only vote in the most important categories, using the minimum amount of web requests
2. Will vote in all categories (but almost always at least the most important), using much decreased amount of web requests
3. (default) Will vote in all categories (but almost always at least the most important), using the same amount of webrequest a real voter would use (except for images, scripts and other page content)
