//
//  ideaDetailViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 17/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class IdeaDetailViewController: UIViewController {
    @IBOutlet weak var detailTopView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var enhancedButton: UIButton!
    @IBOutlet weak var ideaTextView: UITextView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var ideaView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!

    var idea: Idea?
    private var comments: [Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        handleNotification()
        readFireStoreCommentsData()
    }

    @IBAction func pressedCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressEnhancedButton() {
        guard let idea = idea else {
            return
        }
        FirestoreManagement.shared.updateIdeaFromEnhanceToEnhanced(ideaID: idea.documentID)
        pressedCancelButton()
    }

    @IBAction func didPressSubmitButton() {
        if let comment = commentTextField.text, comment != "" {
            guard let ideaID = idea?.documentID else {
                return
            }
            FirestoreManagement.shared.uploadIdeaCommentFirestoreData(comment: comment, ideaID: ideaID)
            readFireStoreCommentsData()
        } else {
            commentTextField.text = "Please write something"
        }
    }

    private func configure() {
        NotificationCenter.default.addObserver(self,
        selector: #selector(handle(keyboardShowNotification:)),
        name: UIResponder.keyboardDidShowNotification,
        object: nil)
        detailTopView.addShadow(yValue: 45, height: 5, color: #colorLiteral(red: 0.8084151745, green: 0.4952875972, blue: 0.3958609998, alpha: 1))
        ideaView.addViewBorder(borderColor: #colorLiteral(red: 0.7943204045, green: 0.6480303407, blue: 0.4752466083, alpha: 1), borderWith: 1.0, borderCornerRadius: 4)
        commentView.addBorder(borderCornerRadius: 16)
        submitButton.addViewBorder(borderColor: #colorLiteral(red: 0.8084151745, green: 0.4952875972, blue: 0.3958609998, alpha: 1), borderWith: 1.0, borderCornerRadius: 16)
        if let idea = idea {
            ideaTextView.text = idea.idea
            authorLabel.text = idea.author
            if idea.isCompleted == true || idea.author != FirestoreManagement.shared.googleUser {
                enhancedButton.isHidden = true
            } else {
                enhancedButton.addBorder(borderCornerRadius: 14)
            }
        }
    }

    private func handleNotification() {
        let commentsReceivedNotifName = Notification.Name(rawValue: "CommentsReceived")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchIdeaComments),
                                               name: commentsReceivedNotifName,
                                                object: nil)
    }

    private func reloadTableView() {
        commentsTableView.reloadData()
    }

    @objc
    private func handle(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

            guard let commentView = self.commentView, let view = self.view else {
                return
            }
            let constant = keyboardRectangle.height + 4
            let bottomConstraint = NSLayoutConstraint(item: view,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: commentView,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: constant)
            self.view.addConstraint(bottomConstraint)
        }
    }

    @objc private func fetchIdeaComments() {
        guard let idea = idea else {
            return
        }
        for comment in FirestoreManagement.shared.ideaComments {
            print("4 \(idea.documentID)")
            print("5 \(comment.ideaID)")
            if comment.ideaID == idea.documentID {
                if self.comments.contains(comment) == false {
                    self.comments.insert(comment, at: 0)
                }
            }
        }
        reloadTableView()
    }
}

extension IdeaDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentIdeaCell",
                                                       for: indexPath) as? IdeasTableViewCell else {
            return UITableViewCell()
        }

        let comment = comments[indexPath.row]

        cell.configureComment(comment: comment)

        return cell
    }
}
