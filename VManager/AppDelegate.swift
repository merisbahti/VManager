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
    case pending
}

enum Action {
    case startVM()
    case stopVM()
    case setVMStatus(VMStatus)
}

struct State {
    let VMStatus: VMStatus
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let vmName = "dev"
    static let vmHostName = "dev"
    let store: Store<State, Action> = Store(
        initialState: State(VMStatus: VMStatus.pending),
        reducer: { (_, action: Action) in
            switch action {
            case Action.startVM():
                startVM()
                return State(VMStatus: VMStatus.pending)
            case Action.stopVM():
                stopVM()
                return State(VMStatus: VMStatus.pending)
            case Action.setVMStatus(let vmStatus):
                return State(VMStatus: vmStatus)
            }
    }
    )
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var actionButton: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    @IBAction func actionClicked(_ sender: NSMenuItem) {
        switch store.getState().VMStatus {
        case VMStatus.noNetwork:
            store.dispatch(action: Action.startVM())
        case VMStatus.running:
            store.dispatch(action: Action.stopVM())
        case VMStatus.stopped:
            store.dispatch(action: Action.startVM())
        default:
            break
        }

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
          case VMStatus.pending:
            self.actionButton.title = "Pending..."
            self.statusItem.title = "🐒"
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
