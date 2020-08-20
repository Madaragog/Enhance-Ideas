//
//  AutosizeUITextView.swift
//  Enhance Ideas
//
//  Created by Cedric on 20/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class AutosizeUITextView: UITextView {
    var maximalSizeNotScrollable: CGFloat = 200
    var minimumHeightTextView: CGFloat = 35

    var textViewHeightAnchor: NSLayoutConstraint!

    override var contentSize: CGSize {
        didSet {
            if textViewHeightAnchor != nil {
                textViewHeightAnchor.isActive = false
            }
            textViewHeightAnchor = heightAnchor.constraint(equalToConstant: min(maximalSizeNotScrollable,
                                                                                max(minimumHeightTextView,
                                                                                    contentSize.height)))
            textViewHeightAnchor.priority = UILayoutPriority(rawValue: 999)
            textViewHeightAnchor.isActive = true
            self.layoutIfNeeded()
        }
    }
}
