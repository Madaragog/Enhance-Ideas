//
//  Extensions.swift
//  Enhance Ideas
//
//  Created by Cedric on 30/07/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

extension UIView {
//    adds a border with color and ajustable width to a UIView
    public func addViewBorder(borderColor: CGColor, borderWith: CGFloat, borderCornerRadius: CGFloat) {
        self.layer.borderWidth = borderWith
        self.layer.borderColor = borderColor
        self.layer.cornerRadius = borderCornerRadius

    }
// adds simple border to a UIView
    public func addBorder(borderCornerRadius: CGFloat) {
        self.layer.cornerRadius = borderCornerRadius
    }
// adds a shadow to a UIView
    public func addShadow(yValue: Int, height: Int, color: CGColor) {
        let colorTop = UIColor.clear.cgColor
        let colorBottom = color
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: yValue, width: 500, height: height)
        layer.colors = [colorTop, colorBottom]
        self.layer.addSublayer(layer)
    }
}
