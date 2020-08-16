//
//  EnhancedIdeasViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 16/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class EnhancedIdeasViewController: UIViewController {
    @IBOutlet weak var enhancedIdeasTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        enhancedIdeasTableView.reloadData()
    }
}

extension EnhancedIdeasViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirestoreManagement.shared.enhancedIdeas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnhancedIdeaCell",
                                                       for: indexPath) as? IdeasTableViewCell else {
            return UITableViewCell()
        }

        let idea = FirestoreManagement.shared.enhancedIdeas[indexPath.row]

        cell.configure(idea: idea)

        return cell
    }
}
