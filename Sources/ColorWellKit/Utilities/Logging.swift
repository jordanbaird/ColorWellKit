//
//  Logging.swift
//  ColorWellKit
//

import Foundation
import os

private let subsystem: String = {
    let packageName = "ColorWellKit"
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return packageName
    }
    return "\(bundleIdentifier).\(packageName)"
}()

/// A value that the logging system uses to filter related log messages.
struct LogCategory: RawRepresentable {
    let rawValue: String
    let log: OSLog

    init(rawValue: String) {
        self.rawValue = rawValue
        self.log = OSLog(subsystem: subsystem, category: rawValue)
    }
}

extension LogCategory {
    /// The main log category.
    static let main      = LogCategory(rawValue: "main")

    /// The log category to use for the `ColorWellPopover` type.
    static let popover   = LogCategory(rawValue: "ColorWellPopover")

    /// The log category to use for the `ColorComponents` type.
    static let components = LogCategory(rawValue: "ColorComponents")
}

/// Sends a message to the logging system using the given category and log level.
func cwk_log(_ message: String, category: LogCategory = .main, type: OSLogType = .default) {
    os_log("%@", log: category.log, type: type, message)
}
