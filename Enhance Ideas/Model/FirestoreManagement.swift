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
    private let db = Firestore.firestore()

    public func readFirestoreData() {
        db.collection("ideasToEnhance").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let author = document["author"] as? String ?? "df"
                    let idea = document["idea"] as? String ?? "dsf"
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

    public func uploadFirestoreData(idea: String) {
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

    private func handleIdeas(ideas: [Idea]) {
        for idea in ideas {
            if idea.isCompleted == false {
                if ideasToEnhance.contains(idea) == false {
                    ideasToEnhance.insert(idea, at: 0)
                }
            } else {
                if enhancedIdeas.contains(idea) == false {
                    enhancedIdeas.insert(idea, at: 0)
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataReceived"), object: nil)
    }
}
