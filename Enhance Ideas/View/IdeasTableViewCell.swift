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
    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var comment: UITextView!

    var ideaGivenToCell = Idea(documentID: "", author: "", idea: "", isCompleted: true)

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(idea: Idea) {
        ideaGivenToCell = idea
        author.text = idea.author
        self.idea.text = idea.idea
    }

    func configureComment(comment: Comment) {
        commentAuthor.text = comment.author
        self.comment.text = comment.comment
    }
}
