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
    var regrets: [Regret] = []
    var regretsDict: [String: Int] = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        apiController.getRegretsFromFirebase { (error, regrets) in
            if let error = error {
                NSLog("Error fetching from table view: \(error)")
            }
            guard let regrets = regrets else { return }

            if regrets != self.regrets {
                self.regretsDict = [:]
                for regret in regrets {
                    if self.regretsDict.keys.contains(regret.stockSymbol) {
                        guard let currentRegret = self.regretsDict[regret.stockSymbol] else { return }
                        self.regretsDict.updateValue(currentRegret+1, forKey: regret.stockSymbol)
                    } else {
                        self.regretsDict[regret.stockSymbol] = 1
                    }
                }
                self.regrets = regrets
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(regretsDict.keys).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegretCell", for: indexPath)
        cell.textLabel?.text = Array(regretsDict.keys)[indexPath.row]
        cell.detailTextLabel?.text = "\(String(Array(regretsDict.values)[indexPath.row])) regrets"
        return cell
    }

}
