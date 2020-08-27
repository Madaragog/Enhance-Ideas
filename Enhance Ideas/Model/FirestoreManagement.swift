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
    public let storagePath = Storage.storage().reference().child("/userProfilePicture")

    private(set) var ideasToEnhance: [Idea] = []
    private(set) var enhancedIdeas: [Idea] = []
    private(set) var ideaComments: [Comment] = []

    private let db = Firestore.firestore()

    public func uploadProfilePicture(image: UIImage) {
        let imageName = "\(userEmail)ProfilePicture.jpeg"
        let storageRef = storagePath.child(imageName)

        let uploadData = image.jpegData(compressionQuality: 0.05)

        if let uploadData = uploadData {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                    return
                }
                print(metadata!)
            }
        }
    }

    public func readFirestoreIdeasData() {
        SDImageCache.shared.diskCache.removeAllData()
        SDImageCache.shared.clearMemory()
        db.collection("ideasToEnhance").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var ideas: [Idea] = []
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? ""
                    let idea = document["idea"] as? String ?? ""
                    let isCompleted = document["isCompleted"] as? Bool ?? false
                    let authorEmail = document["authorEmail"] as? String ?? ""
                    ideas.append(Idea(documentID: document.documentID,
                                                    author: author,
                                                    idea: idea,
                                                    isCompleted: isCompleted, authorEmail: authorEmail))
                }
                self.handleIdeas(ideas: ideas)
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
                var comments: [Comment] = []
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? ""
                    let comment = document["comment"] as? String ?? ""
                    let ideaID = document["ideaID"] as? String ?? ""
                    let authorEmail = document["authorEmail"] as? String ?? ""
                    let noSpaceIdeaID = ideaID.replacingOccurrences(of: " ", with: "")
                    comments.append(Comment(commentID: document.documentID,
                                            ideaID: noSpaceIdeaID,
                                            author: author,
                                            comment: comment, authorEmail: authorEmail))
                }
                self.handleComments(comments: comments)
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
// When the author decides that an idea is now enhanced
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
// When an idea (its text) is modified
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
// When a comment (its text) is modified
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
// separates enhanced and non enhanced ideas and verifies if an idea is not already
// downloaded before adding it to the arrays that will displays them
    func handleIdeas(ideas: [Idea]) {
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
//    verifies if a comment is not already downloaded before adding it to the arrays that will displays them
    func handleComments(comments: [Comment]) {
         for comment in comments where ideaComments.contains(comment) == false {
             ideaComments.insert(comment, at: 0)
         }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CommentsReceived"), object: nil)
    }
}
