//
//  BackgroundTaskOperation.swift
//  workmanager
//
//  Created by Sebastian Roth on 10/06/2021.
//

import Foundation
import Alamofire
import os

class BackgroundTaskOperation: Operation {

    private let identifier: String
    private let flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?
    private let inputData: String
    private let backgroundMode: BackgroundMode
    private let requiresNetwork: Bool
    private let reachabilityManager = NetworkReachabilityManager()

    init(_ identifier: String,
         inputData: String,
         flutterPluginRegistrantCallback: FlutterPluginRegistrantCallback?,
         backgroundMode: BackgroundMode,
         requiresNetwork: Bool = false) {
        self.identifier = identifier
        self.inputData = inputData
        self.flutterPluginRegistrantCallback = flutterPluginRegistrantCallback
        self.backgroundMode = backgroundMode
        self.requiresNetwork = requiresNetwork
    }

    override func main() {
        guard !isCancelled else { return }

        if requiresNetwork {
            if reachabilityManager?.isReachable ?? false {
                executeTask()
            } else {
                logInfo("CartonCloudLogger-WorkManager Operation with identifier \(identifier) is postponing until network is reachable")

                reachabilityManager?.startListening { [weak self] status in
                    guard let self = self, !self.isCancelled else { return }

                    if status == .reachable(.ethernetOrWiFi) || status == .reachable(.cellular) {
                        logInfo("CartonCloudLogger-WorkManager Operation with identifier \(identifier) is resumed")
                        self.reachabilityManager?.stopListening()
                        self.executeTask()
                    }
                }
            }
        } else {
            executeTask()
        }
    }

    private func executeTask() {
        logInfo("CartonCloudLogger-WorkManager Operation with identifier \(identifier) is starting")

        let semaphore = DispatchSemaphore(value: 0)
        let worker = BackgroundWorker(mode: self.backgroundMode,
                                      inputData: self.inputData,
                                      flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback)
        DispatchQueue.main.async {
            worker.performBackgroundRequest { result in
                if result == .failed {
                    logError("CartonCloudLogger-WorkManager Operation with identifier \(self.identifier) failed")
                    if let queue = self.queue {
                        logInfo("CartonCloudLogger-WorkManager Operation with identifier \(self.identifier) is re-adding itself to the queue")
                        queue.addOperation(BackgroundTaskOperation(self.identifier,
                                                                   inputData: self.inputData,
                                                                   flutterPluginRegistrantCallback: self.flutterPluginRegistrantCallback,
                                                                   backgroundMode: self.backgroundMode,
                                                                   requiresNetwork: self.requiresNetwork))
                    }
                }
                semaphore.signal()
            }
        }

        semaphore.wait()
        logInfo("CartonCloudLogger-WorkManager Operation with identifier \(identifier) is finishing")
    }
}