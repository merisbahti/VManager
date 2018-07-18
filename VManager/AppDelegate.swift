//
//  AppDelegate.swift
//  VManager
//
//  Created by meris on 2018-07-16.
//  Copyright © 2018 meris. All rights reserved.
//

import Cocoa

enum VMStatus {
    case running
    case noNetwork
    case stopped
}

enum Action {
    case toggleVMStatus()
    case setVMStatus(VMStatus)
}

struct State {
    let VMStatus: VMStatus
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let vmName = "dev"
    static let vmHostName = "dev.local"
    let store: Store<State, Action> = Store(
        initialState: State(VMStatus: VMStatus.stopped),
        reducer: { (state: State, action: Action) in
            switch action {
            case Action.toggleVMStatus():
                if state.VMStatus == VMStatus.running {
                    stopVM()
                } else {
                    startVM()
                }
                return state
            case Action.setVMStatus(let vmStatus):
                return State(VMStatus: vmStatus)
            }
    }
    )
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var actionButton: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBAction func actionClicked(_ sender: NSMenuItem) {
        store.dispatch(action: Action.toggleVMStatus())
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
      NSApplication.shared.terminate(self)
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
      statusItem.menu = statusMenu
      self.store.subscribe { (state) in
        DispatchQueue.main.async {
          switch state.VMStatus {
          case VMStatus.stopped:
            self.actionButton.title = "Start VM"
            self.statusItem.title = "😭"
          case VMStatus.noNetwork:
            self.actionButton.title = "Start VM"
            self.statusItem.title = "🙉"
          case VMStatus.running:
            self.actionButton.title = "Stop VM"
            self.statusItem.title = "😎"
          }
        }
      }
      startTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
      timer?.invalidate()
    }

    func checkVMStatus() {
      isVMRunning(callback: { vmStatus in
                    self.store.dispatch(action: Action.setVMStatus(vmStatus))
                  })

    }

    weak var timer: Timer?

    func startTimer() {
      self.checkVMStatus()
      timer?.invalidate()
      timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
        self.checkVMStatus()
      }
    }
}
