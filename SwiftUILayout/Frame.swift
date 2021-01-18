//
//  Frame.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/11/2020.
//

import SwiftUI

//  MARK: View + Frame
extension View_ {
	func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment_ = .center) -> some View_ {
		FixedFrame(width: width, height: height, alignment: alignment, content: self)
	}
	
	func frame(minWidth: CGFloat? = nil,
			   idealWidth: CGFloat? = nil,
			   maxWidth: CGFloat? = nil,
			   minHeight: CGFloat? = nil,
			   idealHeight: CGFloat? = nil,
			   maxHeight: CGFloat? = nil,
			   alignment: Alignment_ = .center) -> some View_ {
		FlexibleFrame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment, content: self)
	}
}

//  MARK: Fixed Frame
struct FixedFrame<Content: View_>: View_, IntegratedView {
	var width: CGFloat?
	var height: CGFloat?
	var alignment: Alignment_
	var content: Content
	
	func render(context: RenderingContext, size: CGSize) {
		context.saveGState()
		let childSize = content._size(for: ProposedSize(size))
		let t = translation(for: content, in: size, childSize: childSize, alignment: alignment)
		context.translateBy(x: t.x, y: t.y)
		content._render(context: context, size: childSize)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		if let width = width, let height = height { return CGSize(width: width, height: height) }
		
		let childSize = content._size(for: ProposedSize(width: width ?? proposed.width,
														height: height ?? proposed.height))
		return CGSize(width: width ?? childSize.width,
					  height: height ?? childSize.height)
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		let childSize = content._size(for: ProposedSize(size))
		if let customX = content._customAlignment(for: alignment, in: childSize) {
			let t = translation(for: content, in: size, childSize: childSize, alignment: self.alignment)
			return t.x + customX
		} else { return nil }
	}
	
	var swiftUI: some View { content.swiftUI.frame(width: width, height: height, alignment: alignment.swiftUI) }
}

//  MARK: Flexible Frame
struct FlexibleFrame<Content: View_>: View_, IntegratedView {
	var minWidth: CGFloat?
	var idealWidth: CGFloat?
	var maxWidth: CGFloat?
	var minHeight: CGFloat?
	var idealHeight: CGFloat?
	var maxHeight: CGFloat?
	var alignment: Alignment_
	var content: Content
	
	func render(context: RenderingContext, size: CGSize) {
		context.saveGState()
		let childSize = content._size(for: ProposedSize(size))
		let t = translation(for: content, in: size, childSize: childSize, alignment: alignment)
		context.translateBy(x: t.x, y: t.y)
		content._render(context: context, size: childSize)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		var calculated = ProposedSize(width: proposed.width ?? idealWidth,
									  height: proposed.height ?? idealHeight).orDefault
		if let min = minWidth, min > calculated.width {
			calculated.width = min
		}
		if let max = maxWidth, max < calculated.width {
			calculated.width = max
		}
		
		if let min = minHeight, min > calculated.height {
			calculated.height = min
		}
		if let max = maxHeight, max < calculated.height {
			calculated.height = max
		}
		
		var result = content._size(for: ProposedSize(calculated))
		if let minWidth = minWidth {
			result.width = max(minWidth, min(result.width, calculated.width))
		}
		if let maxWidth = maxWidth {
			result.width = min(maxWidth, max(result.width, calculated.width))
		}
		if let minHeight = minHeight {
			result.height = max(minHeight, min(result.height, calculated.height))
		}
		if let maxHeight = maxHeight {
			result.height = min(maxHeight, max(result.height, calculated.height))
		}
		return result
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		let childSize = content._size(for: ProposedSize(size))
		if let customX = content._customAlignment(for: alignment, in: childSize) {
			let t = translation(for: content, in: size, childSize: childSize, alignment: self.alignment)
			return t.x + customX
		} else { return nil }
	}
	
	var swiftUI: some View { content.swiftUI.frame(minWidth: minWidth, idealWidth: idealWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, maxHeight: maxHeight, alignment: alignment.swiftUI) }
}

//  MARK: Fixed Size
extension View_ {
	func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> some View_ {
		FixedSize(content: self, horizontal: horizontal, vertical: vertical)
	}
}

private struct FixedSize<Content: View_>: View_, IntegratedView {
	var content: Content
	var horizontal: Bool
	var vertical: Bool
	
	func render(context: RenderingContext, size: CGSize) {
		content._render(context: context, size: size)
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		var p = proposed
		if horizontal { p.width = nil }
		if vertical { p.height = nil }
		return content._size(for: p)
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		content._customAlignment(for: alignment, in: size)
	}
	
	var swiftUI: some View { content.swiftUI.fixedSize(horizontal: horizontal, vertical: vertical) }
}
