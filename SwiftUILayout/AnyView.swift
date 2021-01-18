//
//  AnyView.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 30/11/2020.
//

import SwiftUI

//  MARK: Any View
struct AnyView_: View_, IntegratedView {
	let swiftUI: AnyView
	private let anyView: AnyViewBase
	
	init<V: View_>(_ view: V) {
		self.swiftUI = AnyView(view.swiftUI)
		anyView = AnyViewImplementation(view)
	}
	
	func render(context: RenderingContext, size: CGSize) { anyView.render(context: context, size: size) }
	
	func size(for proposed: ProposedSize) -> CGSize { anyView.size(for: proposed) }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		anyView.customAlignment(for: alignment, in: size)
	}
	
	var layoutPriority: Double { anyView.layoutPriority }
}

//  MARK: Type Erasure
private class AnyViewBase: IntegratedView {
	func render(context: RenderingContext, size: CGSize) { fatalError() }
	func size(for proposed: ProposedSize) -> CGSize { fatalError() }
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? { fatalError() }
	var layoutPriority: Double { fatalError() }
}

private final class AnyViewImplementation<V: View_>: AnyViewBase {
	private let view: V
	
	init(_ view: V) { self.view = view }
	
	override func render(context: RenderingContext, size: CGSize) { view._render(context: context, size: size) }
	
	override func size(for proposed: ProposedSize) -> CGSize { view._size(for: proposed) }
	
	override func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
		view._customAlignment(for: alignment, in: size)
	}
	
	override var layoutPriority: Double { view._layoutPriority }
}
