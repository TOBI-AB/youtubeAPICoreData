//
//  CustomView.swift
//  XMLCoreData
//
//  Created by Abdou on 13/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa

class CustomView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override var wantsUpdateLayer: Bool {
        return true
    }

    override func updateLayer() {
        self.layer?.backgroundColor = NSColor(calibratedWhite: 0.4, alpha: 0.7).cgColor
        self.layer?.cornerRadius = 10.0
        self.layer?.masksToBounds = true

    }
}
