//
//  ProgressViewController.swift
//  XMLCoreData
//
//  Created by Abdou on 14/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa

class ProgressViewController: NSViewController {

    @IBOutlet weak var channelTitleLabel: NSTextField!
    @IBOutlet weak var fetchingChannelsProgressView: NSProgressIndicator!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override var representedObject: Any? {
        didSet {
            if let tt = representedObject as? (String, Int) {
                print(tt)
                DispatchQueue.main.async {
                    self.channelTitleLabel.stringValue = tt.0

                }
            }
        }
    }
}

