//
//  UIColor+Extension.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//


import SwiftUI

extension UIColor {
    static func rgb(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    public convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    
    public convenience init(hex: UInt64, includeAlpha: Bool = false) {
        let r, g, b, a: CGFloat

        if !includeAlpha {
            r = CGFloat((hex & 0xFF0000) >> 16) / 255
            g = CGFloat((hex & 0x00FF00) >> 8) / 255
            b = CGFloat((hex & 0x0000FF) >> 0) / 255
            a = 1

        } else {
            r = CGFloat((hex & 0xFF000000) >> 24) / 255
            g = CGFloat((hex & 0x00FF0000) >> 16) / 255
            b = CGFloat((hex & 0x0000FF00) >> 8) / 255
            a = CGFloat(hex & 0x000000FF) / 255
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
        return
    }
    
    
    public convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        if hexString.count != 6 && hexString.count != 8 {
            return nil
        }
        
        guard let hex = hexString.hexInt else { return nil }
        let r, g, b, a: CGFloat
        if hexString.count == 6 {
            r = CGFloat((hex & 0xFF0000) >> 16) / 255
            g = CGFloat((hex & 0x00FF00) >> 8) / 255
            b = CGFloat((hex & 0x0000FF) >> 0) / 255
            a = 1

        } else {
            r = CGFloat((hex & 0xFF000000) >> 24) / 255
            g = CGFloat((hex & 0x00FF0000) >> 16) / 255
            b = CGFloat((hex & 0x0000FF00) >> 8) / 255
            a = CGFloat(hex & 0x000000FF) / 255
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
        return
    }

    
    var rgba: (Int, Int, Int, Float)? {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a: CGFloat = 0
       
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (Int(r * 255.0), Int(g * 255.0), Int(b * 255.0), Float(a))
        } else {
            return nil
        }
    }

    
    func hex<T>(includeAlpha: Bool = false, type: T.Type = String.self ) -> T? {
        if type != String.self && type != UInt64.self {
            return nil
        }
        guard let (r, g, b, a) = self.rgba else {
            return nil
        }
        let hexString: String = if includeAlpha {
            String(format: "%02X%02X%02X%02X", r, g, b, Int(a * 255.0))
        } else {
            String(format: "%02X%02X%02X", r, g, b)
        }
        
        if type == UInt64.self {
            if let hexInt = hexString.hexInt {
                return hexInt as? T
            } else {
                return nil
            }
        } else {
            return "#\(hexString)" as? T
        }
    }
    
    var inverted: UIColor? {
        guard let (r, g, b, a) = self.rgba else {return nil}
        return UIColor.init(255-r, 255-g, 255-b, CGFloat(a))
    }
    
}

extension String {
    var hexInt: UInt64? {
        let scanner = Scanner(string: self)

        var hex: UInt64 = 0
        guard scanner.scanHexInt64(&hex) else {
            return nil
        }
        return hex

    }
}
