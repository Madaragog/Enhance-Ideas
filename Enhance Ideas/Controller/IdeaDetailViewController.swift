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
    @IBOutlet weak var tableViewTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var ideaTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var submitButtonTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var authorProfilePicImageView: UIImageView!

    var idea: Idea?
    var bottomConstraint: NSLayoutConstraint?
    var commentToSend: Comment?
    var cellIndexPath: IndexPath?

    private var comments: [Comment] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        readFireStoreCommentsData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        handleNotifications()
    }

    @IBAction func dissmissKeyboard(_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
    }

    @IBAction func dissmissKeyboardAndSubmit(_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
        didPressSubmitButton()
    }
// when the idea is pressed it shows the detail of it
    @IBAction func authorDidPressIdea(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "IdeaDetailSegue", sender: nil)
    }
// dissmisses the controller
    @IBAction func pressedCancelButton() {
        dismiss(animated: true, completion: nil)
    }
// changes the status of the idea from not enhanced to enhanced
    @IBAction func didPressEnhancedButton() {
        guard let idea = idea else {
            return
        }
        FirestoreManagement.shared.updateIdeaFromEnhanceToEnhanced(ideaID: idea.documentID)
        pressedCancelButton()
    }
// submits the comment
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
// configures the display
    private func configure() {
        authorProfilePicImageView.addViewBorder(borderColor: #colorLiteral(red: 0.8084151745, green: 0.4952875972, blue: 0.3958609998, alpha: 1), borderWith: 1.0, borderCornerRadius: 11)
        if let authorEmail = idea?.authorEmail {
            ProfilePictureViewDownloader().downloadProfilePicture(uIImageView: authorProfilePicImageView,
                                                                       userEmail: authorEmail)
        }
        commentsTableView.rowHeight = UITableView.automaticDimension
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
            if idea.author == FirestoreManagement.shared.googleUser && idea.isCompleted == false {
                ideaTextView.addGestureRecognizer(ideaTapGestureRecognizer)
            }
        }
    }
// adapts the view when the keyboard is shown
    @objc private func handleKeyboardWillShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            guard keyboardFrame != nil && commentView != nil && view != nil else {
                return
            }
            let constant = keyboardFrame!.height + 4
            bottomConstraint = NSLayoutConstraint(item: view!,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: commentView,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: constant)
            guard bottomConstraint != nil else {
                return
            }
            view.addConstraint(bottomConstraint!)
            commentsTableView.addGestureRecognizer(tableViewTapGestureRecognizer)
            submitButton.addGestureRecognizer(submitButtonTapGestureRecognizer)
        }
    }
// puts the view back when the keyboard is resigned
    @objc private func handleKeyboardWillHideNotification(notification: NSNotification) {
        guard bottomConstraint != nil else {
            return
        }
        view.removeConstraint(bottomConstraint!)
        commentsTableView.removeGestureRecognizer(tableViewTapGestureRecognizer)
        submitButton.removeGestureRecognizer(submitButtonTapGestureRecognizer)
    }

    private func handleNotifications() {
        let commentsReceivedNotifName = Notification.Name(rawValue: "CommentsReceived")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchIdeaComments),
                                               name: commentsReceivedNotifName,
                                                object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillShowNotification),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillHideNotification),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        let commentModifiedNotifName = Notification.Name(rawValue: "CommentModified")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deleteOldComment),
                                               name: commentModifiedNotifName,
                                                object: nil)
    }

    private func reloadTableView() {
        commentsTableView.reloadData()
    }

    @objc func deleteOldComment() {
        guard let cellIndexPath = cellIndexPath else {
            return
        }
        comments.remove(at: cellIndexPath.row)
        reloadTableView()
    }

    @objc private func fetchIdeaComments() {
        guard let idea = idea else {
            return
        }
        for comment in FirestoreManagement.shared.ideaComments where
            comment.ideaID == idea.documentID && self.comments.contains(comment) == false {
                self.comments.insert(comment, at: 0)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if commentTextField.isFirstResponder {
            commentTextField.resignFirstResponder()
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? IdeasTableViewCell else {
            return
        }
            print("124")
        commentToSend = cell.commentGivenToCell
        cellIndexPath = indexPath
        self.performSegue(withIdentifier: "CommentDetailSegue", sender: nil)
    }
// swiftlint:disable force_cast
//    prepares the segues dependeing on which one is performed SubmitIdeaViewController
//    wil show the detail of a comment or the detail of the idea
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentDetailSegue" {
            let destinationVC = segue.destination as! SubmitIdeaViewController
            if let commentToSend = self.commentToSend {
                destinationVC.comment = commentToSend
            }
        } else if segue.identifier == "IdeaDetailSegue" {
            let destinationVC = segue.destination as! SubmitIdeaViewController
            if let ideaToSend = self.idea {
                destinationVC.idea = ideaToSend
                destinationVC.ideaComments = self.comments
            }
        }
    }
}
