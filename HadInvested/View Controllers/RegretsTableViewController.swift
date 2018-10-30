//
//  RegretsTableViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class RegretsTableViewController: UITableViewController {
    let apiController = APIController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        apiController.getRegretsFromFirebase { (error, regrets) in
            if let error = error {
                NSLog("Error fetching from table view: \(error)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiController.regrets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegretCell", for: indexPath)
        let regret = apiController.regrets[indexPath.row]
        cell.textLabel?.text = regret.stock
        cell.detailTextLabel?.text = "\(regret.dateOfRegret)"
        return cell
    }
    
}
