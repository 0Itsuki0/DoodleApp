//
//  Array+Extensions.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/10.
//

import SwiftUI

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
