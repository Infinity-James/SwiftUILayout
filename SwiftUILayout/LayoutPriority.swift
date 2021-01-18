//
//  LayoutPriority.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 24/12/2020.
//

import SwiftUI

//  MARK: Layout Priority
struct LayoutPriority<Content: View_>: View_, IntegratedView {
	var content: Content
	var layoutPriority: Double
	
	func render(context: RenderingContext, size: CGSize) {
		content._render(context: context, size: size)
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		content._size(for: proposed)
	}
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		content._customAlignment(for: alignment, in: size)
	}
	
	var swiftUI: some View { content.swiftUI.layoutPriority(layoutPriority) }
}

extension View_ {
	func layoutPriority(_ value: Double) -> some View_ {
		LayoutPriority(content: self, layoutPriority: value)
	}
 }
