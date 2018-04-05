//
//  ViewController.swift
//  Full Screen Clock
//
//  Created by Hal Mueller on 4/4/18.
//  Copyright © 2018 Hal Mueller. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet weak var clockLabel: NSTextField!
	@IBOutlet weak var tickIntervalFormatter: NumberFormatter!
	var beepedSeconds = Int(Date().timeIntervalSinceReferenceDate)
	let tickSound = NSSound(named: NSSound.Name(rawValue: "243748__unfa__metronome-2khz-strong-pulse"))!

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
				print(currentSeconds, currentSecondsInt % 60, UserDefaults.standard.integer(forKey: "tickInterval"))
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		UserDefaults.standard.register(defaults: ["shouldTick" : true, "tickInterval" : 5])
		_ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateClock(timer:)), userInfo: nil, repeats: true)
		print(clockLabel.font?.description as Any)
		clockLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 150.0, weight:NSFont.Weight.regular)
		tickIntervalFormatter.maximumFractionDigits = 0
	}
}

