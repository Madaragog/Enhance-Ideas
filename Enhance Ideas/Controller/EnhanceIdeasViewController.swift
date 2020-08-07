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

//    private var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
          // ...
//        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        Auth.auth().removeStateDidChangeListener(handle!)
    }
}

extension EnhanceIdeasViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
