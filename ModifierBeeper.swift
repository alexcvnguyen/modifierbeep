import Cocoa
import AudioToolbox
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var eventMonitor: Any?
    var isActive = true
    
    // keeps track of which keys were already pressed
    var previousFlags: NSEvent.ModifierFlags = []
    
    // sound stuff
    var pingSound: NSSound?
    
    // how loud the beep is
    var volume: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(Double(volume), forKey: "ModifierBeeperVolume")
            pingSound?.volume = volume
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // grab saved volume or use default
        volume = Float(UserDefaults.standard.double(forKey: "ModifierBeeperVolume"))
        if volume == 0 {
            volume = 1.0 // full blast if not set yet
        }
        
        // get the sound ready
        prepareSound()
        
        // add our little icon to the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // try to use a speaker icon
            if let image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "Modifier Beeper") {
                button.image = image
            } else {
                // emoji fallback if that doesn't work
                button.title = "🔊"
            }
            
            // let us know it's working
            print("modifier beeper is running! listening for key presses...")
        }
        
        setupMenu()
        startMonitoring()
    }
    
    func prepareSound() {
        // load up the ping sound
        if let url = URL(string: "file:///System/Library/Sounds/Ping.aiff") {
            pingSound = NSSound(contentsOf: url, byReference: true)
            pingSound?.volume = volume
            print("sound loaded from \(url.path) at volume \(volume)")
        } else {
            print("couldn't create sound url :(")
        }
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        // on/off toggle
        let toggleItem = NSMenuItem(title: "Active", action: #selector(toggleActive), keyEquivalent: "")
        toggleItem.state = isActive ? .on : .off
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // volume control
        let volumeItem = NSMenuItem(title: "Volume", action: nil, keyEquivalent: "")
        let volumeSliderView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        
        // slider to adjust volume
        let slider = NSSlider(frame: NSRect(x: 70, y: 5, width: 120, height: 20))
        slider.minValue = 0.0
        slider.maxValue = 1.0
        slider.doubleValue = Double(volume)
        slider.target = self
        slider.action = #selector(volumeChanged(_:))
        slider.isContinuous = true
        volumeSliderView.addSubview(slider)
        
        // label for the slider
        let label = NSTextField(frame: NSRect(x: 10, y: 5, width: 60, height: 20))
        label.stringValue = "Volume:"
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.font = NSFont.systemFont(ofSize: 12)
        label.textColor = NSColor.labelColor
        volumeSliderView.addSubview(label)
        
        volumeItem.view = volumeSliderView
        menu.addItem(volumeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // test button
        menu.addItem(NSMenuItem(title: "Test Sound", action: #selector(testSound), keyEquivalent: "t"))
        
        menu.addItem(NSMenuItem.separator())
        
        // quit button
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func volumeChanged(_ sender: NSSlider) {
        volume = Float(sender.doubleValue)
        print("volume set to: \(volume)")
    }
    
    @objc func testSound() {
        // make a test beep
        playSound()
    }
    
    func playSound() {
        // try our main method first - this respects output device
        if let sound = pingSound {
            sound.stop() // stop if already playing
            sound.play() // make the beep
            print("beep! using NSSound through your selected output device at volume \(volume)")
            return
        }
        
        // fallback #1: shell out to afplay
        let task = Process()
        task.launchPath = "/usr/bin/afplay"
        task.arguments = ["-v", String(volume), "/System/Library/Sounds/Ping.aiff"]
        
        do {
            try task.run()
            print("beep! using afplay at volume \(volume)")
        } catch {
            print("uh oh, error playing sound: \(error)")
            
            // fallback #2: last resort system sound
            AudioServicesPlaySystemSound(1104)
            print("beep! using system sound as last resort")
        }
    }
    
    @objc func toggleActive() {
        isActive = !isActive
        if let menu = statusItem.menu {
            menu.item(at: 0)?.state = isActive ? .on : .off
        }
        
        if isActive {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func startMonitoring() {
        stopMonitoring() // clean up any existing monitor
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self, self.isActive else { return }
            
            // check for modifier keys
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            let isShiftPressed = flags.contains(.shift)
            let isCommandPressed = flags.contains(.command)
            let isOptionPressed = flags.contains(.option)
            let isControlPressed = flags.contains(.control)
            
            // only beep for newly pressed keys, not held ones
            let newShiftPress = isShiftPressed && !self.previousFlags.contains(.shift)
            let newCommandPress = isCommandPressed && !self.previousFlags.contains(.command)
            let newOptionPress = isOptionPressed && !self.previousFlags.contains(.option)
            let newControlPress = isControlPressed && !self.previousFlags.contains(.control)
            
            // remember for next time
            self.previousFlags = flags
            
            // beep if any mod key was just pressed
            if newShiftPress || newCommandPress || newOptionPress || newControlPress {
                print("mod key pressed! making noise...")
                self.playSound()
            }
        }
    }
    
    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// kick things off
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()