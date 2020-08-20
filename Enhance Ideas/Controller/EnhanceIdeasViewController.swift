//
//  EnhanceIdeasViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 04/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit
//import Firebase

class EnhanceIdeasViewController: UIViewController {
    @IBOutlet weak var enhanceIdeasTableView: UITableView!
    @IBOutlet weak var addIdeaButton: UIButton!

    var idea: Idea?

    override func viewDidLoad() {
        super.viewDidLoad()
        enhanceIdeasTableView.rowHeight = UITableView.automaticDimension
        readFireStoreIdeasData()
        addIdeaButton.setThemeImage(darkThemeImg: "addIdeaReversedColors", lightThemeImg: "addIdea")
        handleNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        readFireStoreIdeasData()
    }

    private func handleNotifications() {
        ideasNotificationsToReceive()
        let reloadTableViewNotifName = Notification.Name(rawValue: "reloadingTableView")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableView),
                                               name: reloadTableViewNotifName,
                                               object: nil)
    }

    @objc private func reloadTableView() {
        enhanceIdeasTableView.reloadData()
    }
}

extension EnhanceIdeasViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirestoreManagement.shared.ideasToEnhance.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnhanceIdeaCell",
                                                       for: indexPath) as? IdeasTableViewCell else {
            return UITableViewCell()
        }

        let idea = FirestoreManagement.shared.ideasToEnhance[indexPath.row]

        cell.configure(idea: idea)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         guard let cell = tableView.cellForRow(at: indexPath) as? IdeasTableViewCell else {
             return
         }
        idea = cell.ideaGivenToCell
        self.performSegue(withIdentifier: "IdeaToEnhanceDetailSegue", sender: nil)
    }
// swiftlint:disable force_cast
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IdeaToEnhanceDetailSegue" {
            let destinationVC = segue.destination as! IdeaDetailViewController
            if let idea = self.idea {
                destinationVC.idea = idea
            }
        }
    }
}

extension UIViewController {
    func ideasNotificationsToReceive() {
        let dataReceivedNotifName = Notification.Name(rawValue: "dataReceived")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableViewData),
                                               name: dataReceivedNotifName,
                                               object: nil)
    }

    @objc func readFireStoreIdeasData() {
        FirestoreManagement.shared.readFirestoreIdeasData()
    }

    @objc func readFireStoreCommentsData() {
        FirestoreManagement.shared.readFirestoreCommentsData()
    }

    @objc public func reloadTableViewData() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadingTableView"), object: nil)
    }
}
