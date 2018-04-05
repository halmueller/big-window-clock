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

	override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

	func sharedInit () {
		self.postsBoundsChangedNotifications = true
		self.postsFrameChangedNotifications = true
		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.frameChanged(_:)),
											   name: NSView.frameDidChangeNotification,
											   object: nil)
	}

	@objc func frameChanged(_ notification: Notification) {
		print(#function)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}
