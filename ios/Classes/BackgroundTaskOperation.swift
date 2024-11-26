//
//  BackgroundTaskOperation.swift
//  workmanager
//
//  Created by Sebastian Roth on 10/06/2021.
//

import Foundation

class BackgroundTaskOperation: Operation {

    private let identifier: String
    private let flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    private let inputData: String
    private let backgroundMode: BackgroundMode

    init(_ identifier: String,
         inputData: String,
         flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?,
         backgroundMode: BackgroundMode) {
        self.identifier = identifier
        self.inputData = inputData
        self.flutterPluginRegistrantCallback = flutterPluginRegistrantCallback
        self.backgroundMode = backgroundMode
    }

    
    override func main() {
        os_log("Operation with identifier %{public}@ is starting", log: OSLog.default, type: .info, identifier)

        let semaphore = DispatchSemaphore(value: 0)
        let worker = BackgroundWorker(mode: self.backgroundMode,
                                      inputData: self.inputData,
                                      flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback)
        DispatchQueue.main.async {
            worker.performBackgroundRequest { _ in
                semaphore.signal()
            }
        }

        semaphore.wait()
        os_log("Operation with identifier %{public}@ is starting", log: OSLog.default, type: .info, identifier)
    }
}
