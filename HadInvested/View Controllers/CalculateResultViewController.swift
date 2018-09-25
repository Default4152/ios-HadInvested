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
    let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())
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
            let date = date else { return }
        
        let chosenDate = formatter.string(from: datePicker.date)
        let yesterdayAsString = self.formatter.string(from: date)
        
        if isCrypto {
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
                DispatchQueue.main.async {
                    finalAmountLabel.text = "$\(String(format: "%.2f", currentPriceAsDouble * currencyPurchased))"
                    amountHadInvestedLabel.text = "$\(String(format: "%.2f", amount))"
                    symbolLabel.text = symbol
                    dateLabel.text = chosenDate
                }
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
                self.finalAmount = currentPriceAsDouble * stockPurchased
                DispatchQueue.main.async {
                    finalAmountLabel.text = "$\(String(format: "%.2f", currentPriceAsDouble * stockPurchased))"
                    amountHadInvestedLabel.text = "$\(String(format: "%.2f", amount))"
                    symbolLabel.text = symbol
                    dateLabel.text = chosenDate
                }
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
            }
        }
    }

    @IBAction func addRegret(_ sender: Any) {
        // add regret and pop view controller
    }
}
