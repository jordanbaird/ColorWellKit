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

    func testNSColorBlending() {
        continueAfterFailure = false

        func randomColor() -> NSColor {
            NSColor(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1),
                alpha: .random(in: 0...1)
            )
        }

        for _ in 0..<10_000 {
            let color1 = randomColor()
            let color2 = randomColor()

            // it's important to test with fractions that are less than 0 and
            // greater than 1, as they essentially invert the blending
            // algorithm; randomize the stride so that we aren't only testing
            // with "pretty" numbers
            for n in stride(from: -0.1, through: 1.1, by: .random(in: 0.04...0.06)) {
                XCTAssertEqual(
                    color1.blended(withFraction: n, of: color2),
                    color1.blending(fraction: n, of: color2)
                )
            }
        }
    }
}
