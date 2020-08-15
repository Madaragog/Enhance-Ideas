//
//  EnhanceIdeasViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 04/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit
import Firebase

class EnhanceIdeasViewController: UIViewController {
    @IBOutlet weak var ideasToEnhanceTableView: UITableView!
    @IBOutlet weak var addIdeaButton: UIButton!
    @IBOutlet weak var enhanceTabBarItem: UITabBarItem!

    private var ideasToEnhance: [Idea] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        readFirestoreData()
        addIdeaButton.setThemeImage(darkThemeImg: "addIdeaReversedColors", lightThemeImg: "addIdea")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ideasToEnhanceTableView.reloadData()
    }
// swiftlint:disable identifier_name
    private func readFirestoreData() {
        let db = Firestore.firestore()

        db.collection("ideasToEnhance").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let author = document["author"] as? String ?? "df"
                    let idea = document["idea"] as? String ?? "dsf"
                    guard let isCompleted = document["isCompleted"] as? Bool else {
                        return
                    }
                    self.ideasToEnhance.append(Idea(documentID: document.documentID,
                                                    author: author,
                                                    idea: idea,
                                                    isCompleted: isCompleted))
                }
            }
            self.ideasToEnhanceTableView.reloadData()
        }
    }
}

extension EnhanceIdeasViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideasToEnhance.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("3")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell",
                                                       for: indexPath) as? IdeasTableViewCell else {
            return UITableViewCell()
        }

        let idea = ideasToEnhance[indexPath.row]

        cell.configure(idea: idea)

        return cell
    }
}
