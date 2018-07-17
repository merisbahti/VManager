//
//  AppDelegate.swift
//  VManager
//
//  Created by meris on 2018-07-16.
//  Copyright © 2018 meris. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let vmName = "dev"
    let icon = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var status: NSMenuItem!
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = icon
        statusItem.menu = statusMenu
        status.title = "Running"
        startTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    weak var timer: Timer?
    
    func startTimer() {
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            let result = shell(
                launchPath: "/bin/bash",
                arguments: [
                    "-c",
                    "/usr/local/bin/VBoxManage list runningvms | grep dev"
                ]
            )
            let running = result.1 == 0
            self.status.title = running ? "✅ Running" : "❌ Not running"
        }
    }
}


func shell(launchPath: String, arguments: [String]) -> (String?, Int32)
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)
    
    
    return (output, task.terminationStatus)
}

