# modifier beeper

a super simple macos app that beeps when you press any modifier key (shift, command, option, or control).


## what it does

- sits in your menu bar with a little speaker icon
- makes a "ping" sound when you press shift, command, option, or control
- plays through your current audio output (headphones/speakers)
- lets you adjust the volume
- uses practically no resources

## why would i want this?

- i made this help me get used to homerow mods

## how to install

1. download the [latest release](https://github.com/alexcvnguyen/modifierbeep/releases/latest)
2. unzip the file
3. drag ModifierBeeper.app to your Applications folder
4. run it!

the first time you run it, you'll need to:
1. right-click the app and choose "open" (because it's not signed)
2. grant it accessibility permissions when prompted (it needs this to detect key presses)

## how to use

- click the speaker icon in your menu bar to access settings
- use the volume slider to adjust how loud the beep is
- click "test sound" to check if it's working
- click "active" to toggle it on/off
- click "quit" to exit completely

## building from source

if you're a developer type and want to build it yourself:

```bash
# clone the repo
git clone https://github.com/yourusername/modifierbeep.git
cd modifierbeep

# make the build script executable
chmod +x build.sh

# build the app
./build.sh

# run it
open ModifierBeeper.app
```

## license

this is free and open source. do whatever you want with it.
