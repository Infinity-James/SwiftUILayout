//
//  SwiftUILayoutTests.swift
//  SwiftUILayoutTests
//
//  Created by James Valaitis on 11/01/2021.
//

import SwiftUI
@testable import SwiftUILayout
import AppKit
import XCTest

internal final class SwiftUILayoutTests: XCTestCase {
    func textHStack() throws {
        for _ in 0..<10 {
            let frames = (0...Int.random(in: 1..<10)).map { _ in Frame.random() }
            print(frames)
            let subviews = frames.map { $0.view }
            let swiftUIViews = subviews.map { $0.swiftUI }
            let proposedWidth = CGFloat.random(in: 0..<500).rounded()
            let stack = HStack_(children: subviews)
            stack.layout(proposed: ProposedSize(width: proposedWidth, height: 100))
            var swiftUISizes: [CGFloat]!
            let swiftUI = HStack(spacing: 0) {
                ForEach(swiftUIViews.indices) {idx in
                    swiftUIViews[idx]
                        .overlay(GeometryReader { proxy in
                            Color.clear
                                .preference(key: WidthKey.self, value: [proxy.size.width])
                        })
                }
            }
            .frame(width: proposedWidth, height: 100)
            .onPreferenceChange(WidthKey.self) { swiftUISizes = $0 }
            let controller = NSHostingController(rootView: swiftUI)
            controller.view.layout()
            XCTAssertEqual(swiftUISizes, stack.sizes.map { $0.width }, "\(frames) - proposedWidth: \(proposedWidth)")
        }
    }
}

//  MARK: Width
private struct WidthKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

//  MARK: Frame
private enum Frame {
    case flexible
    case fixed(CGFloat)
    case min(CGFloat)
    case max(CGFloat)
    case minMax(CGFloat, CGFloat)
}

extension Frame {
    static func random() -> Frame {
        func randomWidth() -> CGFloat {
            CGFloat.random(in: 0..<200).rounded()
        }
        switch Int.random(in: 0..<5) {
        case 0:
            return .flexible
        case 1:
            return .fixed(randomWidth())
        case 2:
            return .min(randomWidth())
        case 3:
            return .max(randomWidth())
        case 4:
            let random1 = randomWidth()
            let random2 = randomWidth()
            return .minMax(Swift.min(random1, random2), Swift.max(random1, random2))
        default:
            fatalError()
        }
    }
    
    var view: AnyView_ {
        let rect = Rectangle_()
        switch self {
        case .flexible:
            return AnyView_(rect)
        case .fixed(let width):
            return AnyView_(rect.frame(width: width))
        case .min(let width):
            return AnyView_(rect.frame(minWidth: width))
        case .max(let width):
            return AnyView_(rect.frame(maxWidth: width))
        case let .minMax(min, max):
            return AnyView_(rect.frame(minWidth: min, maxWidth: max))
        }
    }
}
