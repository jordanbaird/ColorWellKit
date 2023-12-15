//
//  ColorWellSecondaryActionDelegate.swift
//  ColorWellKit
//

import Foundation

class ColorWellSecondaryActionDelegate: NSObject {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func performAction() {
        action()
    }
}
