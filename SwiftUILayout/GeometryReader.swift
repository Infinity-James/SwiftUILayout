//
//  GeometryReader.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 11/11/2020.
//

import SwiftUI

//  MARK: Geometry Reader
struct GeometryReader_<Content: View_>: View_, IntegratedView {
	let content: (CGSize) -> Content
	
	func render(context: RenderingContext, size: CGSize) {
		let child = content(size)
		context.saveGState()
		let childSize = child._size(for: ProposedSize(size))
		let alignment = Alignment_.topLeading
		let parentPoint = alignment.point(for: size)
		let childPoint = alignment.point(for: childSize)
		context.translateBy(x: parentPoint.x - childPoint.x, y: parentPoint.y - childPoint.y)
		content(size)._render(context: context, size: childSize)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize { proposed.orDefault }
	
	var layoutPriority: Double { 0 }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? { nil }
	
	var swiftUI: some View {
		GeometryReader { proxy in content(proxy.size).swiftUI }
	}
}

//  MARK: Convenience
extension View_ {
	var measured: some View_ {
		overlay(GeometryReader_ { size in
			Text_("\(Int(size.width))")
		})
	}
}
