//
//  HStack.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 30/11/2020.
//

import SwiftUI

//  MARK: Layout State
@propertyWrapper
final class LayoutState<A> {
	var wrappedValue: A
	
	init(wrappedValue: A) {
		self.wrappedValue = wrappedValue
	}
}

//  MARK: Horizontal Stack
struct HStack_: View_, IntegratedView {
	var children: [AnyView_]
	var alignment: VerticalAlignment_ = .center
	var spacing: CGFloat? = 0
	@LayoutState var sizes: [CGSize] = []
	
	func render(context: RenderingContext, size: CGSize) {
		let stackY = alignment.alignmentID.defaultValue(in: size)
		var currentX: CGFloat = 0
		for idx in children.indices {
			let child = children[idx]
			let childSize = sizes[idx]
			let childY = alignment.alignmentID.defaultValue(in: childSize)
			context.saveGState()
			context.translateBy(x: currentX, y: stackY - childY)
			child.render(context: context, size: childSize)
			context.restoreGState()
			currentX += childSize.width
		}
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		layout(proposed: proposed)
		let width = sizes.reduce(0) { $0 + $1.width }
		let height = sizes.reduce(0) { max($0, $1.height) }
		return CGSize(width: width, height: height)
	}
	
	var layoutPriority: Double { 0 }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		guard !alignment.integrated else { return nil }
		var currentX: CGFloat = 0
		var values: [CGFloat] = []
		for idx in children.indices {
			let child = children[idx]
			let childSize = sizes[idx]
			child.customAlignment(for: alignment, in: childSize)
				.flatMap{ values.append($0 + currentX) }
			currentX += childSize.width
		}
		return values.averaged ?? nil
	}
	
	var swiftUI: some View {
		HStack(alignment: alignment.swiftUI, spacing: spacing) {
			ForEach(children.indices, id: \.self) { index in
				children[index].swiftUI
			}
		}
	}
	
	func layout(proposed: ProposedSize) {
		let flexibility: [LayoutInfo] = children.indices
			.map { index in
				let child = children[index]
				let lower = child.size(for: ProposedSize(width: 0, height: proposed.height)).width
				let upper = child.size(for: ProposedSize(width: 1e15, height: proposed.height)).width
				return LayoutInfo(minWidth: lower, maxWidth: upper, index: index, priority: child.layoutPriority)
			}
			.sorted()
		
		var groups = flexibility.group(by: \.priority)
		var sizes: [CGSize] = Array(repeating: .zero, count: children.count)
		let allMinWidths = flexibility.map(\.minWidth).reduce(0, +)
		var remainingWidth = proposed.orMax.width - allMinWidths
		
		while !groups.isEmpty {
			let group = groups.removeFirst()
			remainingWidth += group.map(\.minWidth).reduce(0, +)
			
			var remainingIndices = group.map { $0.index }
			while !remainingIndices.isEmpty {
				let width = remainingWidth / CGFloat(remainingIndices.count)
				let idx = remainingIndices.removeFirst()
				let child = children[idx]
				let size = child.size(for: ProposedSize(width: width, height: proposed.height))
				sizes[idx] = size
				remainingWidth -= size.width
				if remainingWidth < 0 { remainingWidth = 0 }
			}
		}
		self.sizes = sizes
	}
}

//  MARK: Convenience
private extension Array where Element == CGFloat {
	var averaged: CGFloat? {
		guard !isEmpty else { return nil }
		let factor = 1 / CGFloat(count)
		return map { $0 * factor }
			.reduce(0, +)
	}
}

//  MARK: Layout Info
private struct LayoutInfo: Comparable {
	var minWidth: CGFloat
	var maxWidth: CGFloat
	var index: Int
	var priority: Double
	var flexibility: CGFloat { maxWidth - minWidth }
	
	static func <(_ l: LayoutInfo, _ r: LayoutInfo) -> Bool {
		if l.priority > r.priority { return true }
		if r.priority > l.priority { return false }
		return l.flexibility < r.flexibility
	}
}
