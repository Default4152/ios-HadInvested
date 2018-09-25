//
//  RegretsTableViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class RegretsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegretCell", for: indexPath)

        return cell
    }

}
