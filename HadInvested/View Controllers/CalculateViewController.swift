//
//  CalculateViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit

class CalculateViewController: UIViewController {
    let apiController = APIController()
    let formatter = DateFormatter()

    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var isCrypto: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
    }

    @IBAction func calculate(_ sender: Any) {
        guard let symbol = symbolTextField.text,
            let amount = amountTextField.text else { return }
        let chosenDate = formatter.string(from: datePicker.date)

        if isCrypto.isOn {
            apiController.getCryptoData(with: symbol) { (cryptoData) in
                guard let cryptoData = cryptoData,
                    let chosenDateClosePrice = cryptoData.cryptoDaily[chosenDate]?["4a. close (USD)"],
                    let amount = Double(amount) else { return }

                if let profitsHadInvested = Double(chosenDateClosePrice) {
                    print(profitsHadInvested * amount)
                }
            }
        } else {
            // Get stock data for chosen date & today
        }
    }

}
