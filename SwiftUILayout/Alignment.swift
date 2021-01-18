//
//  Alignment.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/12/2020.
//

import SwiftUI

//  MARK: Alignment
struct Alignment_ {
	var horizontal: HorizontalAlignment_
	var vertical: VerticalAlignment_
	
	static let center = Self(horizontal: .center, vertical: .center)
	static let leading = Self(horizontal: .leading, vertical: .center)
	static let trailing = Self(horizontal: .trailing, vertical: .center)
	static let top = Self(horizontal: .center, vertical: .top)
	static let bottom = Self(horizontal: .center, vertical: .bottom)
	static let topLeading = Self(horizontal: .leading, vertical: .top)
	static let topTrailing = Self(horizontal: .trailing, vertical: .top)
	static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)
	static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
	
	var swiftUI: Alignment { Alignment(horizontal: horizontal.swiftUI, vertical: vertical.swiftUI) }
}

extension Alignment_ {
	func point(for size: CGSize) -> CGPoint {
		let x = horizontal.alignmentID.defaultValue(in: size)
		let y = vertical.alignmentID.defaultValue(in: size)
		return CGPoint(x: x, y: y)
	}
}

struct HorizontalAlignment_ {
	var alignmentID: AlignmentID.Type
	var swiftUI: HorizontalAlignment
	var integrated: Bool
	static let leading = Self(alignmentID: HorizontalLeading.self, swiftUI: .leading, integrated: true)
	static let center = Self(alignmentID: HorizontalCenter.self, swiftUI: .center, integrated: true)
	static let trailing = Self(alignmentID: HorizontalTrailing.self, swiftUI: .trailing, integrated: true)
}

extension HorizontalAlignment_ {
	init(alignmentID: AlignmentID.Type, swiftUI: HorizontalAlignment) {
		self.init(alignmentID: alignmentID, swiftUI: swiftUI, integrated: false)
	}
}

struct VerticalAlignment_ {
	var alignmentID: AlignmentID.Type
	var swiftUI: VerticalAlignment
	var integrated: Bool
	static let top = Self(alignmentID: VerticalTop.self, swiftUI: .top, integrated: true)
	static let center = Self(alignmentID: VerticalCenter.self, swiftUI: .center, integrated: true)
	static let bottom = Self(alignmentID: VerticalBottom.self, swiftUI: .bottom, integrated: true)
}

extension VerticalAlignment_ {
	init(alignmentID: AlignmentID.Type, swiftUI: VerticalAlignment) {
		self.init(alignmentID: alignmentID, swiftUI: swiftUI, integrated: false)
	}
}

protocol AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat
}

enum HorizontalLeading: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { 0 }
}

enum HorizontalCenter: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { context.width / 2 }
}

enum HorizontalTrailing: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { context.width }
}

enum VerticalTop: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { context.height }
}

enum VerticalCenter: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { context.height / 2 }
}

enum VerticalBottom: AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { 0 }
}

//  MARK: View + Alignment
extension View_ {
	func translation<V: View_>(for childView: V, in parentSize: CGSize, childSize: CGSize, alignment: Alignment_) -> CGPoint {
		let parentPoint = alignment.point(for: parentSize)
		var childPoint = alignment.point(for: childSize)
		if let customX = childView._customAlignment(for: alignment.horizontal, in: childSize) {
			childPoint.x = customX
		}
		#warning("Vertical axis is missing.")
		return CGPoint(x: parentPoint.x - childPoint.x,
					   y: parentPoint.y - childPoint.y)
	}
	
	func translation<V: View_>(for sibling: V, in size: CGSize, siblingSize: CGSize, alignment: Alignment_) -> CGPoint {
		var point = alignment.point(for: size)
		if let customX = _customAlignment(for: alignment.horizontal, in: siblingSize) {
			point.x = customX
		}
		var childPoint = alignment.point(for: siblingSize)
		if let customX = sibling._customAlignment(for: alignment.horizontal, in: siblingSize) {
			childPoint.x = customX
		}
		#warning("Vertical axis is missing.")
		return CGPoint(x: point.x - childPoint.x,
					   y: point.y - childPoint.y)
	}
}

//  MARK: Custom Alignment
private struct CustomHorizontalAlignmentGuide<Content: View_>: View_, IntegratedView {
	let content: Content
	let alignment: HorizontalAlignment_
	let computeValue: (CGSize) -> CGFloat
	
	func render(context: RenderingContext, size: CGSize) {
		content._render(context: context, size: size)
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		content._size(for: proposed)
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		if alignment.alignmentID == self.alignment.alignmentID { return computeValue(size) }
		else { return content._customAlignment(for: alignment, in: size) }
	}
	
	var swiftUI: some View {
		content.swiftUI.alignmentGuide(alignment.swiftUI,
									   computeValue: { computeValue(CGSize(width: $0.width, height: $0.height)) })
	}
}

extension View_ {
	func alignmentGuide(_ guide: HorizontalAlignment_, computeValue: @escaping (CGSize) -> CGFloat) -> some View_ {
		CustomHorizontalAlignmentGuide(content: self, alignment: guide, computeValue: computeValue)
	}
}
