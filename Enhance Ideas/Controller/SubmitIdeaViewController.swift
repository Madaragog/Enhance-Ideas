//
//  SubmitIdeaViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 16/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class SubmitIdeaViewController: UIViewController {
    @IBOutlet weak var ideaTextView: UITextView!
    @IBOutlet weak var submitIdeaButton: UIButton!
    @IBOutlet weak var submitIdeaTopView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var comment: Comment?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setForDisplayingCommentDetail()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        submitIdeaButton.addBorder(borderCornerRadius: 16)
        submitIdeaTopView.addShadow(yValue: 45, height: 5, color: #colorLiteral(red: 0.8084151745, green: 0.4952875972, blue: 0.3958609998, alpha: 1))
        ideaTextView.addViewBorder(borderColor: #colorLiteral(red: 0.7943204045, green: 0.6480303407, blue: 0.4752466083, alpha: 1), borderWith: 1.0, borderCornerRadius: 4)
        ideaTextView.becomeFirstResponder()
        handleNotification()
    }

    @IBAction func didPressCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressSubmitButton(_ sender: Any) {
        if let idea = ideaTextView.text, idea != "" {
            FirestoreManagement.shared.uploadIdeaFirestoreData(idea: idea)
            dismiss(animated: true, completion: nil)
            readFireStoreIdeasData()
        } else {
            ideaTextView.text = "Please write something"
        }
    }

    @IBAction func didPressModifyButton() {
        if let commentText = ideaTextView.text, commentText != "" {
            guard var comment = comment else {
                return
            }
            comment.comment = commentText
            FirestoreManagement.shared.updateComment(comment: comment)
            dismiss(animated: true, completion: nil)
            readFireStoreIdeasData()
        } else {
            ideaTextView.text = "Please write something"
        }
    }

    @IBAction func didPressDeleteButton() {
        guard let comment = comment else {
            return
        }
        FirestoreManagement.shared.deleteComment(comment: comment)
        dismiss(animated: true, completion: nil)
        readFireStoreIdeasData()
    }

    private func handleNotification() {
        NotificationCenter.default.addObserver(self,
        selector: #selector(handle(keyboardShowNotification:)),
        name: UIResponder.keyboardDidShowNotification,
        object: nil)
    }

    @objc private func setForDisplayingCommentDetail() {
        guard let comment = self.comment else {
            return
        }
        submitIdeaButton.isHidden = true
        cancelButton.addViewBorder(borderColor: #colorLiteral(red: 0.7943204045, green: 0.6480303407, blue: 0.4752466083, alpha: 1), borderWith: 1.0, borderCornerRadius: 16)
        titleLabel.text = "\(comment.author)'s idea !"
        ideaTextView.text = comment.comment
        if comment.author == FirestoreManagement.shared.googleUser {
            deleteButton.isHidden = false
            modifyButton.isHidden = false
            modifyButton.addBorder(borderCornerRadius: 16)
        } else {
            ideaTextView.resignFirstResponder()
            ideaTextView.isUserInteractionEnabled = false
        }
    }

    @objc
    private func handle(keyboardShowNotification notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

            guard let ideaTextView = self.ideaTextView, let view = self.view else {
                return
            }
            let constant = keyboardRectangle.height + 4
            let bottomConstraint = NSLayoutConstraint(item: view,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: ideaTextView,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: constant)
            self.view.addConstraint(bottomConstraint)
        }
    }
}
