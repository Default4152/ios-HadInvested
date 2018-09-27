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
    var regretsSorted: [(key: String, value: Int)] = []
    
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
                        self.regretsDict.updateValue(currentRegret + 1, forKey: regret.stockSymbol)
                    } else {
                        self.regretsDict[regret.stockSymbol] = 1
                    }
                }
                self.regrets = regrets
                self.regretsSorted = self.regretsDict.valueKeySorted
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
        cell.textLabel?.text = regretsSorted[indexPath.row].key
        cell.detailTextLabel?.text = "\(regretsSorted[indexPath.row].value) regrets"
        return cell
    }
    
}

extension Dictionary where Value: Comparable {
    var valueKeySorted: [(Key, Value)] {
        return sorted {
            if $0.value != $1.value {
                return $0.value > $1.value
            } else {
                return String(describing: $0.key) < String(describing: $1.key)
            }
        }
    }
}
