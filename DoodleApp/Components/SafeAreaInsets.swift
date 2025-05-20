//
//  SafeAreaInsets.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI

extension EnvironmentValues {
    public var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

@MainActor
private struct SafeAreaInsetsKey: @preconcurrency EnvironmentKey {
    static var defaultValue: EdgeInsets {
        UIApplication.shared.keyWindow?.safeAreaInsets.insets ?? EdgeInsets()
    }
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {

        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

