//
//  FirestoreManagement.swift
//  Enhance Ideas
//
//  Created by Cedric on 16/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import Foundation
import Firebase
// swiftlint:disable identifier_name redundant_optional_initialization
class FirestoreManagement {
    static let shared = FirestoreManagement()
    private init() {}

    public var googleUser = ""

    private(set) var ideasToEnhance: [Idea] = []
    private(set) var enhancedIdeas: [Idea] = []
    private(set) var ideaComments: [Comment] = []
    private let db = Firestore.firestore()

    public func readFirestoreIdeasData() {
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
                    var ideas: [Idea] = []
                    ideas.append(Idea(documentID: document.documentID,
                                                    author: author,
                                                    idea: idea,
                                                    isCompleted: isCompleted))
                    self.handleIdeas(ideas: ideas)
                }
            }
        }
    }

    public func readFirestoreCommentsData() {
        db.collection("comments").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? ""
                    let comment = document["comment"] as? String ?? ""
                    let ideaID = document["ideaID"] as? String ?? ""
                    let noSpaceIdeaID = ideaID.replacingOccurrences(of: " ", with: "")
                    var comments: [Comment] = []
                    comments.append(Comment(commentID: document.documentID,
                                            ideaID: noSpaceIdeaID,
                                            author: author,
                                            comment: comment))
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
            "isCompleted": false
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
            "ideaID": "\(ideaID)"
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

    public func updateComment(comment: Comment) {
//        if ideaComments.contains(comment) {
//            let comments = ideaComments.filter { $0 != comment }
//            ideaComments = comments
//        }
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
