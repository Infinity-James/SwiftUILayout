//
//  ContentView.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 21/10/2020.
//

import SwiftUI

private struct CustomLeading: AlignmentID, SwiftUI.AlignmentID {
	static func defaultValue(in context: CGSize) -> CGFloat { 0 }
	static func defaultValue(in context: ViewDimensions) -> CGFloat { 0 }
}

private extension HorizontalAlignment_ {
	static var customLeading: HorizontalAlignment_ { HorizontalAlignment_(alignmentID: CustomLeading.self, swiftUI: HorizontalAlignment(CustomLeading.self)) }
}

struct ContentView: View {
	@State var opacity: Double = 0.5
	@State var width: CGFloat = 300
	let size = CGSize(width: 800, height: 600)
	var sample: some View_{
		VerticalGrid(columns: [100, 200], content: [
			AnyView_(Rectangle_().foregroundColor(.red).measured),
			AnyView_(Rectangle_().foregroundColor(.green).frame(minWidth: 74, minHeight: 50).measured),
			AnyView_(Rectangle_().foregroundColor(.orange).frame(maxWidth: 23).measured)
		])
		.border(.gray, width: 2)
		.frame(width: width, height: 200, alignment: Alignment_(horizontal: .leading, vertical: .center))
		.border(.purple, width: 4)
	}
	
	var body: some View {
		VStack {
			Slider(value: $opacity, in: 0...1)
			HStack {
				Text("Custom")
				Spacer()
				Text("SwiftUI")
			}
			HStack {
				Text("Width \(width.rounded())")
				Slider(value: $width, in: 0...600)
			}
			ZStack {
				Image(nsImage: NSImage(data: render(view: sample, size: size))!)
					.opacity(1 - opacity)
				
				sample.swiftUI
					.frame(width: size.width, height: size.height)
					.opacity(opacity)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

extension CGContext {
	static func pdf(size: CGSize, render: (CGContext) -> ()) -> Data {
		let pdfData = NSMutableData()
		let consumer = CGDataConsumer(data: pdfData)!
		var mediaBox = CGRect(origin: .zero, size: size)
		let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)!
		pdfContext.beginPage(mediaBox: &mediaBox)
		render(pdfContext)
		pdfContext.endPage()
		pdfContext.closePDF()
		return pdfData as Data
	}
}
