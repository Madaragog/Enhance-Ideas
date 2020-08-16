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

    override func viewDidLoad() {
        super.viewDidLoad()
        readFireStoreData()
        addIdeaButton.setThemeImage(darkThemeImg: "addIdeaReversedColors", lightThemeImg: "addIdea")
        handleNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        readFireStoreData()
    }

    private func handleNotifications() {
        notificationsToReceive()
        let reloadTableViewNotifName = Notification.Name(rawValue: "reloadingTableView")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableView),
                                               name: reloadTableViewNotifName,
                                               object: nil)
    }

    @objc private func reloadTableView() {
        enhanceIdeasTableView.reloadData()
    }

/*
     private func handleNotification() {
         let dataReceivedNotifName = Notification.Name(rawValue: "dataReceived")
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(reloadTableViewData),
                                                name: dataReceivedNotifName,
                                                object: nil)
         let ideaSubmitedNotifName = Notification.Name(rawValue: "IdeaSubmited")
         NotificationCenter.default.addObserver(self,
                                                selector: #selector(readFireStoreData),
                                                name: ideaSubmitedNotifName,
                                                object: nil)
     }

     @objc private func readFireStoreData() {
         FirestoreManagement.shared.readFirestoreData()
     }

     @objc private func reloadTableViewData() {
         enhanceIdeasTableView.reloadData()
     }
     */
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
}

extension UIViewController {
    func notificationsToReceive() {
        let dataReceivedNotifName = Notification.Name(rawValue: "dataReceived")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadTableViewData),
                                               name: dataReceivedNotifName,
                                               object: nil)
        let ideaSubmitedNotifName = Notification.Name(rawValue: "IdeaSubmited")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(readFireStoreData),
                                               name: ideaSubmitedNotifName,
                                               object: nil)
    }

    @objc func readFireStoreData() {
        FirestoreManagement.shared.readFirestoreData()
    }

    @objc public func reloadTableViewData() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadingTableView"), object: nil)
    }
}
