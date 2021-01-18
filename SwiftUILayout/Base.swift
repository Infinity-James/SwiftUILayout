//
//  Base.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/12/2020.
//

import SwiftUI

//  MARK: View
protocol View_ {
	associatedtype Body: View_
	var body: Body { get }
	
	//	debugging
	associatedtype SwiftUIView: View
	var swiftUI: SwiftUIView { get }
}

extension View_ {
	func _render(context: RenderingContext, size: CGSize) {
		if let integrated = self as? IntegratedView { integrated.render(context: context, size: size) }
		else { body._render(context: context, size: size) }
	}
	
	func _size(for proposed: ProposedSize) -> CGSize {
		if let integrated = self as? IntegratedView { return integrated.size(for: proposed) }
		else { return body._size(for: proposed) }
	}
	
	func _customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		if let integrated = self as? IntegratedView { return integrated.customAlignment(for: alignment, in: size) }
		else { return body._customAlignment(for: alignment, in: size) }
	}
	
	var _layoutPriority: Double {
		if let integrated = self as? IntegratedView { return integrated.layoutPriority }
		else { return body._layoutPriority }
	}
}

//  MARK: Integrated View
protocol IntegratedView {
	func render(context: RenderingContext, size: CGSize)
	func size(for proposed: ProposedSize) -> CGSize
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat?
	var layoutPriority: Double { get }
	typealias Body = Never
}

extension View_ where Body == Never {
	var body: Never { fatalError("This should never be called.") }
}

extension Never: View_ {
	typealias Body = Never
	var swiftUI: Never { fatalError("This should never be called.") }
}

//  MARK: Size
struct ProposedSize {
	var width: CGFloat?
	var height: CGFloat?
}

extension ProposedSize {
	init(_ size: CGSize) {
		self.init(width: size.width, height: size.height)
	}
	
	var orMax: CGSize { CGSize(width: width ?? .greatestFiniteMagnitude, height: height ?? .greatestFiniteMagnitude) }
	var orDefault: CGSize { CGSize(width: width ?? 10, height: height ?? 10) }
}

//  MARK: Context
typealias RenderingContext = CGContext

