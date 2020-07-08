//
//  ViewController.swift
//  Full Screen Clock
//
//  Created by Hal Mueller on 4/4/18.
//  Copyright © 2018 Hal Mueller. All rights reserved.
//

import Cocoa
import IOKit.pwr_mgt

class ViewController: NSViewController {

	@IBOutlet weak var clockLabel: ResizingLabel!
	@IBOutlet weak var tickIntervalFormatter: NumberFormatter!
	@IBOutlet weak var currentTimeFormatter: DateFormatter!
	@IBOutlet weak var showTimezoneCheckbox: NSButton!
	@IBOutlet weak var disbleSleepCheckbox: NSButton!
    @IBOutlet weak var useUTCCheckbox: NSButton!

	var beepedSeconds = Int(Date().timeIntervalSinceReferenceDate)
	// source: https://freesound.org/people/unfa/sounds/243748/ Creative Commons 0 License
	let tickSound = NSSound(named: "243748__unfa__metronome-2khz-strong-pulse")!

	var  assertionID = IOPMAssertionID(kIOPMNullAssertionID)

	@objc func updateClock(timer: Timer) {
		let currentTime = NSDate()
		let currentSeconds = currentTime.timeIntervalSinceReferenceDate
		let currentSecondsInt = Int(currentSeconds)
		self.clockLabel.objectValue = currentTime
		if currentSecondsInt != beepedSeconds {
			if UserDefaults.standard.bool(forKey: "shouldTick") &&
				currentSecondsInt % UserDefaults.standard.integer(forKey: "tickInterval") == 0 {
				tickSound.stop()
				tickSound.play()
				beepedSeconds = currentSecondsInt
			}
		}
	}

    func configureTimeFormatter() {
        if UserDefaults.standard.bool(forKey: "useUTC") {
            currentTimeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if UserDefaults.standard.bool(forKey: "showTimezone") {
                currentTimeFormatter.dateFormat = "HH:mm:ss'Z'"
            }
            else {
                currentTimeFormatter.dateFormat = "HH:mm:ss"
            }
        }
        else {
            currentTimeFormatter.timeZone = TimeZone.current
            if UserDefaults.standard.bool(forKey: "showTimezone") {
                currentTimeFormatter.dateFormat = "HH:mm:ssZ"
            }
            else {
                currentTimeFormatter.dateFormat = "HH:mm:ss"
            }
        }
        self.clockLabel.frameChanged(nil)
    }
    
	func configureSleepDisable() {
		if UserDefaults.standard.bool(forKey: "disableSleep") {
		}
		else {
		}
	}

	@IBAction func toggleShowTimezone(_ sender: NSButton) {
        let currentValue = UserDefaults.standard.bool(forKey: "showTimezone")
        UserDefaults.standard.set(!currentValue, forKey: "showTimezone")
        configureTimeFormatter()
	}

    @IBAction func toggleUseUTC(_ sender: NSButton) {
        let currentValue = UserDefaults.standard.bool(forKey: "useUTC")
        UserDefaults.standard.set(!currentValue, forKey: "useUTC")
        configureTimeFormatter()
    }
    
    
	@IBAction func toggleDisableSleep(_ sender: NSButton) {
		let newShouldDisableSleep = !UserDefaults.standard.bool(forKey: "disableSleep")
		UserDefaults.standard.set(newShouldDisableSleep, forKey: "disableSleep")
		if newShouldDisableSleep {
			createNosleepAssert()
		}
		else {
			releaseNosleepAssert()
		}
	}

	func createNosleepAssert() {
		let reasonForActivity = "Big Window Clock disable sleep requested" as CFString
		let sleepKey = kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString
		_ = IOPMAssertionCreateWithName(sleepKey, IOPMAssertionLevel(kIOPMAssertionLevelOn), reasonForActivity, &assertionID)
	}

	func releaseNosleepAssert() {
		IOPMAssertionRelease(assertionID)
		assertionID = IOPMAssertionID(kIOPMNullAssertionID)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		UserDefaults.standard.register(defaults: ["shouldTick" : true,
												  "tickInterval" : 5,
												  "showTimezone" : false,
												  "disableSleep" : true])
		configureTimeFormatter()
		if UserDefaults.standard.bool(forKey: "disableSleep") {
			createNosleepAssert()
			disbleSleepCheckbox.state = .on
		}
		else {
			disbleSleepCheckbox.state = .off
		}
		if UserDefaults.standard.bool(forKey: "showTimezone") {
			showTimezoneCheckbox.state = .on
		} else {
			showTimezoneCheckbox.state = .off
		}
        if UserDefaults.standard.bool(forKey: "useUTC") {
            useUTCCheckbox.state = .on
        } else {
            useUTCCheckbox.state = .off
        }
		if let existingFont = clockLabel.font {
			clockLabel.font = NSFont.monospacedDigitSystemFont(ofSize: existingFont.pointSize, weight:NSFont.Weight.regular)
		}
		tickIntervalFormatter.maximumFractionDigits = 0
		_ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateClock(timer:)), userInfo: nil, repeats: true)
	}
}

