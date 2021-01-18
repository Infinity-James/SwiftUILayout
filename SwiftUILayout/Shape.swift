//
//  Shape.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/12/2020.
//

import SwiftUI

struct AnyShape: Shape {
	let path: (CGRect) -> CGPath
	init<S: Shape_>(shape: S) {
		path = shape.path(in:)
	}
	func path(in rect: CGRect) -> Path { Path(path(rect)) }
}

struct ShapeView<S: Shape_>: IntegratedView, View_ {
	var shape: S
	var swiftUI: some View { AnyShape(shape: shape) }
	
	func render(context: RenderingContext, size: CGSize) {
		context.saveGState()
		context.addPath(shape.path(in: CGRect(origin: .zero, size: size)))
		context.fillPath()
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize { proposed.orDefault }
	
	var layoutPriority: Double { 0 }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? { nil }
}

protocol Shape_: View_ {
	func path(in rect: CGRect) -> CGPath
}

extension Shape_ {
	var body: some View_ { ShapeView(shape: self) }
	var swiftUI: AnyShape { AnyShape(shape: self) }
}

extension NSColor: View_ {
	var body: some View_ { Rectangle_().foregroundColor(self) }
	var swiftUI: some View { Color(self) }
}

struct Rectangle_: Shape_ {
	func path(in rect: CGRect) -> CGPath {
		CGPath(rect: rect, transform: nil)
	}
}

struct Ellipse_: Shape_ {
	func path(in rect: CGRect) -> CGPath {
		CGPath(ellipseIn: rect, transform: nil)
	}
}

func render<V: View_>(view: V, size: CGSize) -> Data {
	return CGContext.pdf(size: size) { context in
		view
			.frame(width: size.width, height: size.height)
			._render(context: context, size: size)
	}
}
