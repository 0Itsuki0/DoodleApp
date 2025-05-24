//
//  CGRect+Extensions.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/24.
//

import Foundation

extension CGRect {
    var isBounded: Bool {
        !self.isInfinite && !self.isNull && !self.isEmpty
    }
}
