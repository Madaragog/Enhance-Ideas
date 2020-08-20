//
//  UIButtonExtension.swift
//  Enhance Ideas
//
//  Created by Cedric on 20/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

extension UIButton {
// sets the image depending on the theme (dark mode or light mode)
    public func setThemeImage(darkThemeImg: String, lightThemeImg: String) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                self.setImage(UIImage(named: darkThemeImg), for: .normal)
            }
        } else {
            self.setImage(UIImage(named: lightThemeImg), for: .normal)
        }
    }
}
