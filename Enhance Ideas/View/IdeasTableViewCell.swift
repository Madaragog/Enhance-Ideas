//
//  IdeasTableViewCell.swift
//  Enhance Ideas
//
//  Created by Cedric on 14/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class IdeasTableViewCell: UITableViewCell {
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var idea: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(idea: Idea) {
        author.text = idea.author
        self.idea.text = idea.idea
    }
}
