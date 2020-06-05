//
//  DebugLogger.swift
//  ClubKit
//
//  Created by Chrishon Wyllie on 6/2/20.
//

import Foundation

public class DebugLogger {
    
    public static let shared = DebugLogger()
    private var debugMessages: [String] = []
    private var withNsLog = true
    
    private init(withNsLog: Bool = true) {
        self.withNsLog = withNsLog
        clear()
    }
    
    public func toggleDebug() {
        let key = ClubConstants.DebugMode.debugModeUserDefaultsKey
        let currentBoolValue = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.set(!currentBoolValue, forKey: key)
    }
    
    public func addDebugMessage(_ message: String) {
        if
            UserDefaults.standard.bool(forKey: ClubConstants.DebugMode.debugModeActivatedKey) == false
            || UserDefaults.standard.bool(forKey: ClubConstants.DebugMode.debugModeUserDefaultsKey) == false {
            return
        }
        if self.withNsLog {
            #if DEBUG
            NSLog(message)
            #endif
        }
        debugMessages.append(message)
    }
    
    public func getAllMessages() -> [String] {
        return debugMessages
    }
    
    public func clear() {
        debugMessages.removeAll()
    }
}