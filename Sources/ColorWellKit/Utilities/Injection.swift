//
//  Injection.swift
//  ColorWellKit
//

/// Calls the given closure with an `inout` version of the given argument.
///
/// - Parameters:
///   - value: A value to pass to `body` as an `inout` parameter.
///   - body: A closure that takes an `inout` version of `value`. If the
///     closure has a return value, that value is also used as the return
///     value of the `with(_:body:)` function.
///
/// - Returns: Whatever value is returned from `body`.
func with<T, U>(_ value: T, body: (inout T) throws -> U) rethrows -> U {
    var copy = value
    return try body(&copy)
}
