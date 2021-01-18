//
//  Border.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 16/12/2020.
//

import SwiftUI

//  MARK: Border
extension View_ {
	func border(_ color: NSColor, width: CGFloat) -> some View_ {
		overlay(BorderShape(width: width).foregroundColor(color))
	}
}

struct BorderShape: Shape_ {
	var width: CGFloat
	
	func path(in rect: CGRect) -> CGPath {
		CGPath(rect: rect.insetBy(dx: width / 2, dy: width / 2), transform: nil)
			.copy(strokingWithWidth: width, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
	}
}
