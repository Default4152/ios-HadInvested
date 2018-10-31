//
//  RegretsTableViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class RegretsTableViewController: UITableViewController {
    private var filteredRegrets: [Regret] = []
    let apiController = APIController()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        apiController.getRegretsFromFirebase { (error, regrets) in
            if let error = error {
                NSLog("Error fetching from table view: \(error)")
            }
            
            guard let regrets = regrets else { return }
    
            self.filteredRegrets = regrets
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRegrets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegretCell", for: indexPath)
        let regret = filteredRegrets[indexPath.row]
        cell.textLabel?.text = regret.stock
        cell.detailTextLabel?.text = "\(regret.dateOfRegret)"
        return cell
    }
    
}

extension RegretsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        let filtered = apiController.regrets.filter({  $0.stock.lowercased().contains(searchText) })
        self.filteredRegrets = filtered.isEmpty ? apiController.regrets : filtered
        tableView.reloadData()
    }
}
