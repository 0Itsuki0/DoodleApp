//
//  Array+Extensions.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/10.
//

import SwiftUI

extension Array where Element: Comparable, Element: SignedNumeric {
    func closestIndex(to element: Element) -> Int {
        let sorted = self.sorted()

        let overIndex = sorted.firstIndex(where: { $0 >= element }) ?? self.count - 1
        let underIndex = sorted.lastIndex(where: { $0 <= element }) ?? 0

        
        let diffOver = self[overIndex] - element
        let diffUnder = self[underIndex] - element

        return (diffOver < diffUnder) ? overIndex : underIndex
        
    }

}
