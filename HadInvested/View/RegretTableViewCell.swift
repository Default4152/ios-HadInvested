//
//  RegretTableViewCell.swift
//  HadInvested
//
//  Created by Conner on 10/31/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class RegretTableViewCell: UITableViewCell {
    var regret: Regret? {
        didSet {
            updateViews()
        }
    }
    
    var parentRestorationIdentifier: String?
    
    @IBOutlet var amountCalculatedLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var stockLabel: UILabel!
    
    private func updateViews() {
        guard let parentRestorationIdentifer = parentRestorationIdentifier else { return }
        
        if let regret = regret {
            if parentRestorationIdentifer == "PublicRegretsStoryboard" {
                amountLabel.text = regret.author
                amountCalculatedLabel.text = "$\(regret.finalAmount.rounded(toPlaces: 2))"
                dateLabel.text = regret.dateOfRegret
                stockLabel.text = regret.stock
            } else {
                amountLabel.text = "$\(regret.amount)"
                amountCalculatedLabel.text = "$\(regret.finalAmount.rounded(toPlaces: 2))"
                dateLabel.text = regret.dateOfRegret
                stockLabel.text = regret.stock
            }
        }
    }
}
