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
    @IBOutlet var ideaTextAndAuthorView: UIView!
    @IBOutlet weak var authorPPImageView: UIImageView!

    var ideaGivenToCell = Idea(documentID: "", author: "", idea: "", isCompleted: true)
    var commentGivenToCell = Comment(ideaID: "", author: "", comment: "")

    var maximalSizeNotScrollable: CGFloat = 200
    var minimumHeightTextView: CGFloat = 35
    var textViewHeightAnchor: NSLayoutConstraint!
    let pPDownloader = ProfilePictureViewDownloader()
// sets the style of the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        ideaTextAndAuthorView.addShadow(yValue: 0, height: 5, color: #colorLiteral(red: 0.8084151745, green: 0.4952875972, blue: 0.3958609998, alpha: 1))
        authorPPImageView.addViewBorder(borderColor: #colorLiteral(red: 0.7943204045, green: 0.6480303407, blue: 0.4752466083, alpha: 1), borderWith: 1.0, borderCornerRadius: 10)
    }
// configures the cell if it has to display an idea
    func configure(idea: Idea) {
        ideaGivenToCell = idea
        author.text = idea.author
        self.idea.text = idea.idea
        pPDownloader.downloadProfilePicture(uIImageView: authorPPImageView, userEmail: idea.authorEmail)
    }
    // configures the cell if it has to display an comment
    func configureComment(comment: Comment) {
        commentGivenToCell = comment
        commentAuthor.text = comment.author
        self.comment.text = comment.comment
        pPDownloader.downloadProfilePicture(uIImageView: authorPPImageView, userEmail: comment.authorEmail)
    }
}
