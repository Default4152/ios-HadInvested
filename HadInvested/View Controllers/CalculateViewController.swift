//
//  CalculateViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CalculateViewController: UIViewController, NVActivityIndicatorViewable {
    let apiController = APIController()
    let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    let formatter = DateFormatter()
    let activityData = ActivityData(size: nil,
                                    message: "Calculating...",
                                    messageFont: nil,
                                    messageSpacing: nil,
                                    type: .squareSpin,
                                    color: nil,
                                    padding: nil,
                                    displayTimeThreshold: nil,
                                    minimumDisplayTime: 2,
                                    backgroundColor: .gray,
                                    textColor: nil)

    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var isCrypto: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
    }

    @IBAction func calculate(_ sender: Any) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
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
                    let currentPriceAsDouble = Double(currentPrice) else {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        return
                }

                let currencyPurchased = amount / closePriceAsDouble
                print(currentPriceAsDouble * currencyPurchased)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        } else {
            apiController.getStockData(with: symbol) { (stockData) in
                guard let stockData = stockData,
                    let currentPrice = stockData.timeSeriesDaily[yesterdayAsString]?.close,
                    let chosenDateClosePrice = stockData.timeSeriesDaily[chosenDate]?.close,
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        return
                }
                let stockPurchased = amount / closePriceAsDouble
                print(currentPriceAsDouble * stockPurchased)
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        }
    }
}
