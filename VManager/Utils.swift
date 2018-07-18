import Cocoa

func isVMRunning(callback: @escaping (VMStatus) -> Void) {
  shell(
    launchPath: "/bin/bash",
    arguments: [
      "-c",
      "ping -c 1 -t 1 \(AppDelegate.vmHostName)"
    ],
    callback: { _, code in
      if code == 0 {
        callback(VMStatus.running)
        return
      }
      shell(
        launchPath: "/bin/bash",
        arguments: [
          "-c",
          "/usr/local/bin/VBoxManage list runningvms | grep \(AppDelegate.vmName)"
        ],
        callback: { _, code in
          callback(code == 0 ? VMStatus.noNetwork : VMStatus.stopped)
        }
      )
    }
  )
}

fileprivate func shell(launchPath: String, arguments: [String], callback: ((String?, Int32) -> Void)? = nil) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    task.terminationHandler = { _ in
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)
        callback?(output, task.terminationStatus)
    }
}

func startVM() {
  shell(
    launchPath: "/bin/bash",
    arguments: [
      "-c",
      "/usr/local/bin/VBoxManage startvm \(AppDelegate.vmName) --type headless"
    ]
  )
}

func stopVM() {
  shell(
    launchPath: "/bin/bash",
    arguments: [
      "-c",
      "/usr/local/bin/VBoxManage controlvm \(AppDelegate.vmName) poweroff"
    ]
  )
}
