//
//  CalculateResultViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CalculateResultViewController: UIViewController, NVActivityIndicatorViewable {
    var amount: String?
    var symbol: String?
    var isCrypto: Bool = false
    var apiController = APIController()
    let yesterdaysDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    let formatter = DateFormatter()
    var finalAmount = 0.0
    var datePicker: UIDatePicker?

    @IBOutlet var amountHadInvestedLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var finalAmountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"

        fetchData()
    }

    func fetchData() {
        guard let amountHadInvestedLabel = amountHadInvestedLabel,
            let symbolLabel = symbolLabel,
            let dateLabel = dateLabel,
            let finalAmountLabel = finalAmountLabel,
            let amount = amount,
            let symbol = symbol,
            let datePicker = datePicker,
            let yesterdaysDate = yesterdaysDate else { return }

        let chosenDate = formatter.string(from: datePicker.date)
        let yesterdayAsString = self.formatter.string(from: yesterdaysDate)

        if isCrypto {
            apiController.getCryptoData(with: symbol) { (cryptoData) in
                guard let cryptoData = cryptoData,
                    let currentPrice = cryptoData.cryptoDaily[yesterdayAsString]?["1a. open (USD)"],
                    let chosenDateClosePrice = cryptoData.cryptoDaily[chosenDate]?["4a. close (USD)"],
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        }
                        return
                }

                let currencyPurchased = amount / closePriceAsDouble
                DispatchQueue.main.async {
                    if currentPriceAsDouble * currencyPurchased < amount {
                        finalAmountLabel.textColor = .red
                    }
                    finalAmountLabel.text = "$\(String(format: "%.2f", currentPriceAsDouble * currencyPurchased))"
                    amountHadInvestedLabel.text = "$\(String(format: "%.2f", amount))"
                    symbolLabel.text = symbol.uppercased()
                    dateLabel.text = chosenDate
                }
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        } else {
            apiController.getStockData(with: symbol) { (stockData) in
                guard let stockData = stockData,
                    let currentPrice = stockData.timeSeriesDaily[yesterdayAsString]?.adjustedClose,
                    let chosenDateClosePrice = stockData.timeSeriesDaily[chosenDate]?.adjustedClose,
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else {
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        }
                        return
                }
                let stockPurchased = amount / closePriceAsDouble
                self.finalAmount = currentPriceAsDouble * stockPurchased
                DispatchQueue.main.async {
                    if currentPriceAsDouble * stockPurchased < amount {
                        finalAmountLabel.textColor = .red
                    }
                    finalAmountLabel.text = "$\(String(format: "%.2f", currentPriceAsDouble * stockPurchased))"
                    amountHadInvestedLabel.text = "$\(String(format: "%.2f", amount))"
                    symbolLabel.text = symbol.uppercased()
                    dateLabel.text = chosenDate
                }
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        }
    }

    @IBAction func addRegret(_ sender: Any) {
        guard let symbol = symbol else { return }
        let regret = Regret(dateOfRegret: formatter.string(from: Date()), stockSymbol: symbol)
        apiController.putRegretToFirebase(with: regret) { (error) in
            if let error = error {
                NSLog("Error putting regret to firebase via addRegret: \(error)")
                return
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
