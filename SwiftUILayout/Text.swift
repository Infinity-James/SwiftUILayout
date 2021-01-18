//
//  Text.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 09/11/2020.
//

import SwiftUI

//  MARK: Text
struct Text_: View_, IntegratedView {
	let text: String
	let font = NSFont.systemFont(ofSize: 16)
	
	init(_ text: String) {
		self.text = text
	}
	
	private var attributes: [NSAttributedString.Key: Any] {
		[.font: font,
		 .foregroundColor: NSColor.white]
	}
		
	private var frameSetter: CTFramesetter {
		let string = NSAttributedString(string: text, attributes: attributes)
		return CTFramesetterCreateWithAttributedString(string)
	}
	
	func render(context: RenderingContext, size: CGSize) {
		let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
		let frame = CTFramesetterCreateFrame(frameSetter, CFRange(), path, nil)
		context.saveGState()
		CTFrameDraw(frame, context)
		context.restoreGState()
	}
	
	func size(for proposed: ProposedSize) -> CGSize {
		CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(), nil, proposed.orMax, nil)
	}
	
	var layoutPriority: Double { 0 }
	
	func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? { nil }
	
	var swiftUI: some View { Text(text).font(Font(font)) }
}
