//
//  Overlay.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 09/11/2020.
//

import SwiftUI

//  MARK: Overlay
extension View_ {
	func overlay<O: View_>(_ overlay: O, alignment: Alignment_ = .center) -> some View_ {
		Overlay(content: self, overlay: overlay, alignment: alignment)
	}
}

struct Overlay<Content: View_, O: View_>: View_, IntegratedView {
	let content: Content
	let overlay: O
	let alignment: Alignment_
	
	func render(context: RenderingContext, size: CGSize) {
		content._render(context: context, size: size)
		context.saveGState()
		let childSize = overlay._size(for: ProposedSize(size))
		let t = content.translation(for: overlay, in: size, siblingSize: childSize, alignment: alignment)
		context.translateBy(x: t.x, y: t.y)
		overlay._render(context: context, size: childSize)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		content._size(for: proposed)
	}
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		content._customAlignment(for: alignment, in: size)
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	var swiftUI: some View { content.swiftUI.overlay(overlay.swiftUI, alignment: alignment.swiftUI) }
	
}
