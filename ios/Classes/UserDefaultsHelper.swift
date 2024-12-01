//
//  WorkmanagerUserDefaultsHelper.swift
//  workmanager
//
//  Created by Kymer Gryson on 13/08/2019.
//

import Foundation

struct UserDefaultsHelper {

    // MARK: Properties

    private static let userDefaults = UserDefaults(suiteName: "\(SwiftWorkmanagerPlugin.identifier).userDefaults")!

    enum Key {
        case callbackHandle
        case pendingTasks
        case isDebug

        var stringValue: String {
            return "\(SwiftWorkmanagerPlugin.identifier).\(self)"
        }
    }

    // MARK: callbackHandle

    static func storeCallbackHandle(_ handle: Int64) {
       store(handle, key: .callbackHandle)
    }

    static func getStoredCallbackHandle() -> Int64? {
        return getValue(for: .callbackHandle)
    }

    // MARK: hasPendingTasks

    static func storePendingTasks(_ pendingTasks: Int16) {
        store(pendingTasks, key: .pendingTasks)
    }

    static func getStoredPendingTasks() -> Int16 {
        return getValue(for: .pendingTasks) ?? 0
    }

    static func increasePendingTasksCount() {
        let currentCount = getStoredPendingTasks()
        store(currentCount + 1, key: .pendingTasks)
    }

    static func decreasePendingTasksCount() {
        let currentCount = getStoredPendingTasks()
        if currentCount > 0 {
            store(currentCount - 1, key: .pendingTasks)
        }
    }

    // MARK: isDebug

    static func storeIsDebug(_ isDebug: Bool) {
        store(isDebug, key: .isDebug)
    }

    static func getIsDebug() -> Bool {
        return getValue(for: .isDebug) ?? false
    }

    // MARK: Private helper functions

    private static func store<T>(_ value: T, key: Key) {
        userDefaults.setValue(value, forKey: key.stringValue)
    }

    private static func getValue<T>(for key: Key) -> T? {
        return userDefaults.value(forKey: key.stringValue) as? T
    }

}
