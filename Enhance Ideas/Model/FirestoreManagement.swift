//
//  FirestoreManagement.swift
//  Enhance Ideas
//
//  Created by Cedric on 16/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

// swiftlint:disable identifier_name redundant_optional_initialization
class FirestoreManagement {
    static let shared = FirestoreManagement()
    private init() {}

    public var googleUser = ""
    public var userEmail = ""

    private(set) var ideasToEnhance: [Idea] = []
    private(set) var enhancedIdeas: [Idea] = []
    private(set) var ideaComments: [Comment] = []
    private let db = Firestore.firestore()

    public func uploadProfilePicture(image: UIImage) {
        let imageName = "\(userEmail)ProfilePicture.jpeg"
        let storageRef = Storage.storage().reference().child("/userProfilePicture").child(imageName)

        let uploadData = image.jpegData(compressionQuality: 0.05)

        if let uploadData = uploadData {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
//                    NotificationCenter.default.post(name:
//                        NSNotification.Name(rawValue: "profilePicError"),
//                                                    object: nil)
                    return
                }
                print(metadata!)
//                NotificationCenter.default.post(name:
//                NSNotification.Name(rawValue: "fetchPP"),
//                                            object: nil)
            }
        }
    }

    public func downloadProfilePicture(uIImageView: UIImageView, userEmail: String) {
        let imageName = "\(userEmail)ProfilePicture.jpeg"
        let storageRef = Storage.storage().reference().child("/userProfilePicture").child(imageName)
        // UIImageView in your ViewController
        let imageView: UIImageView = uIImageView
        // Placeholder image
        let placeholderImage = UIImage(named: "placeholder.jpg")
        // Load the image using SDWebImage
        imageView.sd_setImage(with: storageRef, placeholderImage: placeholderImage)
    }

    public func readFirestoreIdeasData() {
        SDImageCache.shared.diskCache.removeAllData()
        SDImageCache.shared.clearMemory()
        db.collection("ideasToEnhance").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? ""
                    let idea = document["idea"] as? String ?? ""
                    guard let isCompleted = document["isCompleted"] as? Bool else {
                        return
                    }
                    let authorEmail = document["authorEmail"] as? String ?? ""
                    var ideas: [Idea] = []
                    ideas.append(Idea(documentID: document.documentID,
                                                    author: author,
                                                    idea: idea,
                                                    isCompleted: isCompleted, authorEmail: authorEmail))
                    self.handleIdeas(ideas: ideas)
                }
            }
        }
    }

    public func readFirestoreCommentsData() {
        SDImageCache.shared.diskCache.removeAllData()
        SDImageCache.shared.clearMemory()
        db.collection("comments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? ""
                    let comment = document["comment"] as? String ?? ""
                    let ideaID = document["ideaID"] as? String ?? ""
                    let authorEmail = document["authorEmail"] as? String ?? ""
                    let noSpaceIdeaID = ideaID.replacingOccurrences(of: " ", with: "")
                    var comments: [Comment] = []
                    comments.append(Comment(commentID: document.documentID,
                                            ideaID: noSpaceIdeaID,
                                            author: author,
                                            comment: comment, authorEmail: authorEmail))
                    self.handleComments(comments: comments)
                }
            }
        }
    }

    public func uploadIdeaFirestoreData(idea: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("ideasToEnhance").addDocument(data: [
            "author": "\(googleUser)",
            "idea": "\(idea)",
            "isCompleted": false,
            "authorEmail": "\(userEmail)"
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    public func uploadIdeaCommentFirestoreData(comment: String, ideaID: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("comments").addDocument(data: [
            "author": "\(googleUser)",
            "comment": "\(comment)",
            "ideaID": "\(ideaID)",
            "authorEmail": "\(userEmail)"
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }

    public func updateIdeaFromEnhanceToEnhanced(ideaID: String) {
        let idea = db.collection("ideasToEnhance").document(ideaID)
        idea.updateData([
            "isCompleted": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.ideasToEnhance.removeAll()
                self.readFirestoreIdeasData()
            }
        }
    }

    public func updateIdea(idea: Idea) {
        ideasToEnhance.removeAll()
        let ref = db.collection("ideasToEnhance").document(idea.documentID)
        ref.updateData([
            "idea": "\(idea.idea)"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    public func updateComment(comment: Comment) {
        let ref = db.collection("comments").document(comment.commentID)
        ref.updateData([
            "comment": "\(comment.comment)"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.ideaComments.removeAll()
                self.readFirestoreCommentsData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CommentModified"), object: nil)
            }
        }
    }

    public func deleteComment(comment: Comment) {
        db.collection("comments").document(comment.commentID).delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.ideaComments.removeAll()
                self.readFirestoreCommentsData()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CommentModified"), object: nil)
            }
        }
    }

    public func deleteIdea(idea: Idea) {
        ideasToEnhance.removeAll()
        db.collection("ideasToEnhance").document(idea.documentID).delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

    private func handleIdeas(ideas: [Idea]) {
        let uncompletedIdeas = ideas.filter { $0.isCompleted == false }
        let completedIdeas = ideas.filter { $0.isCompleted == true }

        for uncompleteIdea in uncompletedIdeas where ideasToEnhance.contains(uncompleteIdea) == false {
            ideasToEnhance.insert(uncompleteIdea, at: 0)
        }
        for completedIdea in completedIdeas where enhancedIdeas.contains(completedIdea) == false {
            enhancedIdeas.insert(completedIdea, at: 0)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataReceived"), object: nil)
    }

    private func handleComments(comments: [Comment]) {
        for comment in comments where ideaComments.contains(comment) == false {
            ideaComments.insert(comment, at: 0)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CommentsReceived"), object: nil)
    }
}
