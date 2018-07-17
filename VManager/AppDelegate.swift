//
//  AppDelegate.swift
//  VManager
//
//  Created by meris on 2018-07-16.
//  Copyright © 2018 meris. All rights reserved.
//

import Cocoa

enum VMStatus {
    case Running
    case NoNetwork
    case Stopped
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let vmName = "dev"
    static let vmHostName = "dev.local"
    var vmStatus = VMStatus.Stopped;
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var status: NSMenuItem!
    
    @IBAction func actionClicked(_ sender: NSMenuItem) {
        switch self.vmStatus
        {
        case VMStatus.Stopped:
            startVM()
        case VMStatus.NoNetwork:
            startVM()
        case VMStatus.Running:
            stopVM()
        }
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.title = ""
        statusItem.menu = statusMenu
        startTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func checkVMStatus() {
        self.vmStatus = isVMRunning()
        switch self.vmStatus
        {
        case VMStatus.Stopped:
            self.status.title = "Start VM"
            self.statusItem.title = "😭"
        case VMStatus.NoNetwork:
            self.status.title = "Start VM"
            self.statusItem.title = "🙉"
        case VMStatus.Running:
            self.status.title = "Stop VM"
            self.statusItem.title = "😎"
        }
    }


    weak var timer: Timer?
    
    func startTimer() {
        self.checkVMStatus()
        timer?.invalidate()   // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            self.checkVMStatus()
        }
    }
}

func isVMRunning() -> VMStatus
{
    let pingResult = shell(
        launchPath: "/bin/bash",
        arguments: [
            "-c",
            "ping -c 1 -t 1 \(AppDelegate.vmHostName)"
        ]
    )
    if (pingResult.1 == 0) {
        return VMStatus.Running;
    }
    let result = shell(
        launchPath: "/bin/bash",
        arguments: [
            "-c",
            "/usr/local/bin/VBoxManage list runningvms | grep \(AppDelegate.vmName)"
        ]
    )
    return result.1 == 0 ? VMStatus.NoNetwork : VMStatus.Stopped
}

func startVM() -> Void
{
    shell(
        launchPath: "/bin/bash",
        arguments: [
            "-c",
            "/usr/local/bin/VBoxManage startvm \(AppDelegate.vmName) --type headless"
        ]
    )
}

func stopVM() -> Void
{
    shell(
        launchPath: "/bin/bash",
        arguments: [
            "-c",
            "/usr/local/bin/VBoxManage controlvm \(AppDelegate.vmName) poweroff"
        ]
    )
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
    task.waitUntilExit()
    
    return (output, task.terminationStatus)
}

