//
//  ColorWellKitTests.swift
//  ColorWellKit
//

import XCTest
@testable import ColorWellKit

final class ColorWellKitTests: XCTestCase {
    func testCGRectCenter() {
        let rect1 = CGRect(x: 0, y: 0, width: 500, height: 500)
        let rect2 = CGRect(x: 1000, y: 1000, width: 250, height: 250)
        let rect3 = rect2.centered(in: rect1)
        XCTAssertEqual(rect3.origin.x, rect1.midX - (rect3.width / 2))
        XCTAssertEqual(rect3.origin.y, rect1.midY - (rect3.height / 2))
    }
}
