//
//  EnhanceIdeasViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 04/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit

class EnhanceIdeasViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
