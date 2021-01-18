//
//  Color.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/11/2020.
//

import SwiftUI

extension View_ {
	func foregroundColor(_ color: NSColor) -> some View_ {
		ForegroundColor(content: self, color: color)
	}
}

struct ForegroundColor<Content: View_>: View_, IntegratedView {
	var content: Content
	var color: NSColor
	
	func render(context: RenderingContext, size: CGSize) {
		context.saveGState()
		context.setFillColor(color.cgColor)
		content._render(context: context, size: size)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		content._size(for: proposed)
	}
	
	var layoutPriority: Double { content._layoutPriority }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		content._customAlignment(for: alignment, in: size)
	}
	
	var swiftUI: some View {
		content.swiftUI.foregroundColor(Color(color))
	}
}
