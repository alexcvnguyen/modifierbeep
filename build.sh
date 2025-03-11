#!/bin/bash

# clean up old stuff
rm -rf ModifierBeeper.app

# make the folders we need
mkdir -p ModifierBeeper.app/Contents/MacOS
mkdir -p ModifierBeeper.app/Contents/Resources

# copy the config file
cp Info.plist ModifierBeeper.app/Contents/

# do the build
swiftc -o ModifierBeeper.app/Contents/MacOS/ModifierBeeper ModifierBeeper.swift

# check if it worked
if [ $? -eq 0 ]; then
    # make it executable
    chmod +x ModifierBeeper.app/Contents/MacOS/ModifierBeeper
    echo "all done! your app is ready at ModifierBeeper.app"
    echo "run it with: open ModifierBeeper.app"
    echo ""
    echo "important stuff to know:"
    echo "1. you'll need to allow the app in system settings -> security & privacy -> general"
    echo "2. you'll need to grant accessibility permissions in system settings -> security & privacy -> privacy -> accessibility"
    echo "3. make sure your volume isn't muted"
    echo ""
    echo "if you don't hear anything, try clicking the menu bar icon and hit 'test sound'"
else
    echo "build failed :( check the errors above"
fi