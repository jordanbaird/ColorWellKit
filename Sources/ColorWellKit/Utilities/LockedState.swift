//
//  LockedState.swift
//  ColorWellKit
//

import os

/// A locking wrapper around a state.
///
/// This implementation is heavily inspired by Foundation's `LockedState` type:
/// https://github.com/apple/swift-foundation/blob/main/Sources/FoundationEssentials/LockedState.swift
struct LockedState<State> {
    private enum Lock {
        typealias UnfairLock = os_unfair_lock

        static func initialize(_ lock: UnsafeMutablePointer<UnfairLock>) {
            lock.initialize(to: UnfairLock())
        }

        static func deinitialize(_ lock: UnsafeMutablePointer<UnfairLock>) {
            lock.deinitialize(count: 1)
        }

        static func lock(_ lock: UnsafeMutablePointer<UnfairLock>) {
            os_unfair_lock_lock(lock)
        }

        static func unlock(_ lock: UnsafeMutablePointer<UnfairLock>) {
            os_unfair_lock_unlock(lock)
        }
    }

    private class Buffer: ManagedBuffer<State, Lock.UnfairLock> {
        deinit {
            withUnsafeMutablePointerToElements { lock in
                Lock.deinitialize(lock)
            }
        }
    }

    private let buffer: ManagedBuffer<State, Lock.UnfairLock>

    var state: State {
        buffer.withUnsafeMutablePointerToHeader { state in
            state.pointee
        }
    }

    init(initialState: State) {
        self.buffer = Buffer.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { lock in
                Lock.initialize(lock)
            }
            return initialState
        }
    }

    func withLock<T>(_ body: (inout State) throws -> T) rethrows -> T {
        try buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            defer {
                Lock.unlock(lock)
            }
            return try body(&state.pointee)
        }
    }

    func withLockExtendingLifetimeOfState<T>(_ body: (inout State) throws -> T) rethrows -> T {
        try buffer.withUnsafeMutablePointers { state, lock in
            Lock.lock(lock)
            return try withExtendedLifetime(state.pointee) {
                defer {
                    Lock.unlock(lock)
                }
                return try body(&state.pointee)
            }
        }
    }
}
