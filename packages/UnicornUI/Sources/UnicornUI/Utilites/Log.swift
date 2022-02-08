//
//  Created by Andrew Podkovyrin on 13.01.2022.
//

import Foundation
import os.log

@inlinable
func dui_log(_ message: @autoclosure () -> String) {
    // Same configuration as using DDOSLogger.sharedInstance from CocoaLumberjack
    os_log("[UnicornUI] %{public}@", log: .default, type: .error, message())
}

@inlinable
func dui_assertLog(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) {
    if !condition() {
        let _message = message()
        // swiftlint:disable:next compiler_protocol_init
        dui_log("🛑 \(NSString(stringLiteral: file).lastPathComponent):\(line) \(function)" + _message)
        Swift.assertionFailure(_message, file: file, line: line)
    }
}

@inlinable
func dui_assertionFailureLog(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) {
    let _message = message()
    // swiftlint:disable:next compiler_protocol_init
    dui_log("🛑 \(NSString(stringLiteral: file).lastPathComponent):\(line) \(function)" + _message)
    Swift.assertionFailure(_message, file: file, line: line)
}

@inlinable
func dui_assertNonMainThread(
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) {
    if Thread.isMainThread {
        // swiftlint:disable:next compiler_protocol_init
        dui_log("🛑 NON MainThread Violation \(NSString(stringLiteral: file).lastPathComponent):\(line) \(function)")
        Swift.assertionFailure(file: file, line: line)
    }
}
