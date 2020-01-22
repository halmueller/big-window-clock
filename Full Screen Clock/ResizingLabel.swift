//
//  ResizingLabel.swift
//  Full Screen Clock
//
//  Created by Hal Mueller on 4/4/18.
//  Copyright © 2018 Hal Mueller. All rights reserved.
//

import Cocoa

class ResizingLabel: NSTextField {

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	func sharedInit () {
		self.postsBoundsChangedNotifications = true
		self.postsFrameChangedNotifications = true
		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.frameChanged(_:)),
											   name: NSView.frameDidChangeNotification,
											   object: nil)
	}

	@objc func frameChanged(_ notification: Notification?) {
		font = maximumSizedFont()
	}

	func fontTooSmall(string: String, font: NSFont, frameRect: NSRect) -> Bool {
		let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: font])
		let tooSmall = stringSize.width < frameRect.width && stringSize.height < frameRect.height
		return tooSmall
	}

	func fontTooLarge(string: String, font: NSFont, frameRect: NSRect) -> Bool {
		let stringSize = string.size(withAttributes: [NSAttributedString.Key.font: font])
		let tooLarge = stringSize.width >= frameRect.width || stringSize.height >= frameRect.height
		return tooLarge
	}

	func maximumSizedFont() -> NSFont {
		var resultFont = self.font ?? NSFont.monospacedDigitSystemFont(ofSize: 30.0, weight: NSFont.Weight.semibold)

		while fontTooSmall(string: self.stringValue, font: resultFont, frameRect: self.frame) {
			resultFont = NSFont.monospacedDigitSystemFont(ofSize: resultFont.pointSize + 1.0, weight: NSFont.Weight.semibold)
		}

		while fontTooLarge(string: self.stringValue, font: resultFont, frameRect: self.frame) {
			resultFont = NSFont.monospacedDigitSystemFont(ofSize: resultFont.pointSize - 1.0, weight: NSFont.Weight.semibold)
		}
		return resultFont
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}
