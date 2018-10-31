//
//  RegretTableViewCell.swift
//  HadInvested
//
//  Created by Conner on 10/31/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class RegretTableViewCell: UITableViewCell {
    @IBOutlet var amountCalculatedLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var stockLabel: UILabel!
    
    private func updateViews() {
        if let regret = regret {
            amountCalculatedLabel.text = "$\(regret.finalAmount.rounded(toPlaces: 2))"
            dateLabel.text = regret.dateOfRegret
            amountLabel.text = "$\(regret.amount)"
            stockLabel.text = regret.stock
        }
    }
    
    var regret: Regret? {
        didSet {
            updateViews()
        }
    }
}
