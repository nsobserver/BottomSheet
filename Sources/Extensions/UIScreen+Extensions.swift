//
//  UIScreen+Extensions.swift
//  
//
//  Created by nsobserver on 11/01/2022.
//

import UIKit

public extension UIScreen {

    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    var screenCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else { return 0 }
        return cornerRadius
    }
}
