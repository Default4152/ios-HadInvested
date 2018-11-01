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
    let dateFormatter = DateFormatter()
    let regretDateFormatter = DateFormatter()
    
    @IBOutlet var amountCalculatedLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var stockLabel: UILabel!
    
    private func updateViews() {
        guard let parentRestorationIdentifer = parentRestorationIdentifier else { return }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        regretDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

        if let regret = regret {
            guard let dateOfRegret = regretDateFormatter.date(from: regret.dateOfRegret) else { return }
            if parentRestorationIdentifer == "PublicRegretsStoryboard" {
                amountLabel.textColor = .red
                amountLabel.text = regret.author
                amountCalculatedLabel.text = "\(formatCurrency(value: regret.finalAmount))"
                dateLabel.text = dateFormatter.string(from: dateOfRegret)
                stockLabel.text = regret.stock
            } else {
                amountLabel.text = "$\(regret.amount)"
                amountCalculatedLabel.text = "\(formatCurrency(value: regret.finalAmount))"
                dateLabel.text = dateFormatter.string(from: dateOfRegret)
                stockLabel.text = regret.stock
            }
        }
    }
    
    private func formatCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: value as NSNumber)
        return result!
    }
}
