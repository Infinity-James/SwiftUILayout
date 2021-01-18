//
//  Helpers.swift
//  SwiftUILayout
//
//  Created by James Valaitis on 28/12/2020.
//

import Foundation

extension Array {
	// expects the array to be sorted by groupId
	func group<A: Equatable>(by groupID: (Element) -> A) -> [[Element]] {
		guard !isEmpty else { return [] }
		var groups: [[Element]] = []
		var currentGroup: [Element] = [self[0]]
		for element in dropFirst() {
			if groupID(currentGroup[0]) == groupID(element) {
				currentGroup.append(element)
			} else {
				groups.append(currentGroup)
				currentGroup = [element]
			}
		}
		groups.append(currentGroup)
		return groups
	}
}
