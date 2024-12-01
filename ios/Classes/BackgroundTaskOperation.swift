//
//  BackgroundTaskOperation.swift
//  workmanager
//
//  Created by Sebastian Roth on 10/06/2021.
//

import Foundation
import os

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
        logInfo("CartonCloudLogger - WorkManager Operation with identifier \(identifier) is starting")

        let semaphore = DispatchSemaphore(value: 0)
        let worker = BackgroundWorker(mode: self.backgroundMode,
                                      inputData: self.inputData,
                                      flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback)
        DispatchQueue.main.async {
            worker.performBackgroundRequest { result in
                if result == .failed {
                    logError("CartonCloudLogger - WorkManager Operation with identifier \(self.identifier) failed")
                } else {
                    UserDefaultsHelper.decreasePendingTasksCount()
                }
                semaphore.signal()
            }
        }

        semaphore.wait()
        logInfo("CartonCloudLogger - WorkManager Operation with identifier \(identifier) is finishing")
    }
}
