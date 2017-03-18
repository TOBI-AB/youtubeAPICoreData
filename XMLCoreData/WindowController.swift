//
//  WindowController.swift
//  XMLCoreData
//
//  Created by Abdou on 14/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {


    lazy var screen: NSScreen = {
        guard let screen = NSScreen.main() else {
            return NSScreen()
        }
        return screen
    }()

    override func windowDidLoad() {
        super.windowDidLoad()

        if let frame = self.window?.contentView?.frame {
            let windowX = (self.screen.visibleFrame.size.width / 2) - (frame.width / 2)
            let windowY = self.screen.visibleFrame.size.height - frame.height
            let windowOrigin = CGPoint(x: windowX, y: windowY)
            self.window?.setFrame(NSRect(origin: windowOrigin, size: CGSize(width: 800, height: self.screen.visibleFrame.height)), display: true)
        }
    }

}
