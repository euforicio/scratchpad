//
//  AppDelegate.swift
//  VimTextView
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-15.
//

import Cocoa
import libvim

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        vimInit()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

