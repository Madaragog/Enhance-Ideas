//
//  Enhance_IdeasTests.swift
//  Enhance IdeasTests
//
//  Created by Cedric on 23/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import XCTest
@testable import Enhance_Ideas
import Firebase

class EnhanceIdeasTests: XCTestCase {
    let firestore = FirestoreManagement.shared

    func testHandleIdeas() {
//        given
        let ideas = [
            Idea(documentID: "j4j4jk4",
                 author: "ced",
                 idea: "this is the Idea",
                 isCompleted: true,
                 authorEmail: "ced@gmail.com"),
            Idea(documentID: "456789dsgaf",
                 author: "didier",
                 idea: "this is didier's idea",
                 isCompleted: false,
                 authorEmail: "didi@gmail.com")
        ]
//        when
        firestore.handleIdeas(ideas: ideas)
//        then
        XCTAssertEqual(firestore.ideasToEnhance[0].documentID, "456789dsgaf")
        XCTAssertEqual(firestore.enhancedIdeas[0].documentID, "j4j4jk4")
    }

    func testHandleComments() {
//        given
        let comments = [
            Comment(commentID: "hjhj45355",
                    ideaID: "skjdfakl43r",
                    author: "lorient",
                    comment: "yeah it's me",
                    authorEmail: "lorient@gmail.com"),
            Comment(commentID: "hjhj45355",
                    ideaID: "skjdfakl43r",
                    author: "lorient",
                    comment: "yeah it's me",
                    authorEmail: "lorient@gmail.com"),
            Comment(commentID: "sdjf4jk34r",
                    ideaID: "fjk34jtnt4",
                    author: "me",
                    comment: "you know me, right ?",
                    authorEmail: "meitis@gmail.com")
        ]
//        when
        firestore.handleComments(comments: comments)
//        then
        XCTAssertTrue(firestore.ideaComments.count == 2)
    }
}
