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
    let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
            let amount = amountTextField.text,
            let yesterday = date else { return }

        let chosenDate = formatter.string(from: datePicker.date)
        let yesterdayAsString = self.formatter.string(from: yesterday)

        if isCrypto.isOn {
            apiController.getCryptoData(with: symbol) { (cryptoData) in
                guard let cryptoData = cryptoData,
                    let currentPrice = cryptoData.cryptoDaily[yesterdayAsString]?["1a. open (USD)"],
                    let chosenDateClosePrice = cryptoData.cryptoDaily[chosenDate]?["4a. close (USD)"],
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else { return }

                let currencyPurchased = amount / closePriceAsDouble
                print(currentPriceAsDouble * currencyPurchased)
            }
        } else {
            apiController.getStockData(with: symbol) { (stockData) in
                guard let stockData = stockData,
                    let currentPrice = stockData.timeSeriesDaily[yesterdayAsString]?.close,
                    let chosenDateClosePrice = stockData.timeSeriesDaily[chosenDate]?.close,
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else {
                    // Alert users with alert that we do not have data for the chosen date, try again
                        return
                }
                let stockPurchased = amount / closePriceAsDouble
                print(currentPriceAsDouble * stockPurchased)
            }
        }
    }
}
