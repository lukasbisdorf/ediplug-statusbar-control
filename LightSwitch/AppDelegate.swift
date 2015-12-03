//
//  AppDelegate.swift
//  LightSwitch
//
//  Created by Lukas Bisdorf on 02.12.15.
//  Copyright © 2015 Lukas Bisdorf. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var statusMenuItem: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    let schreibtisch = switchController(username: "admin", password: "stromanaus", host: "10.50.2.34")
    
    let SWITCH_ON_STATE_LABEL = "Lampe ausschalten!"
    let SWITCH_OFF_STATE_LABEL = "Lampe einschalten!"

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let iconOn = NSImage(named: "statusOn")
        let iconOff = NSImage(named: "statusOff")
        

        statusItem.image = iconOff
        statusItem.menu = statusMenu
        
        schreibtisch.events.listenTo("off", action: self.statusChanged)
        schreibtisch.events.listenTo("on", action: self.statusChanged)
        
        schreibtisch.getStatus()
        var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "checkStatus",userInfo: nil, repeats: true)
        
    }
    
    func checkStatus() {
        schreibtisch.getStatus()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func statusChanged(information: Any?) {
        if let info = information as? String {
            if info == "on" {
                statusItem.image = NSImage(named: "statusOn")
                statusMenuItem.title = SWITCH_ON_STATE_LABEL
            }
            if info == "off" {
                statusItem.image = NSImage(named: "statusOff")
                statusMenuItem.title = SWITCH_OFF_STATE_LABEL
            }
        }
    }
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        
        if(sender.title == SWITCH_ON_STATE_LABEL) {
            statusItem.image = NSImage(named: "statusOff")
            schreibtisch.turnOff()
            
        }
        else {
            statusItem.image = NSImage(named: "statusOn")
            schreibtisch.turnOn()
        }
        
    }

}

