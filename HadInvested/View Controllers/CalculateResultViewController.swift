//
//  CalculateResultViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SCLAlertView

class CalculateResultViewController: UIViewController, NVActivityIndicatorViewable {
    // MARK: - Properties
    var apiController = APIController()
    var amount: String?
    var symbol: String?
    var todaysPrice: StockData?
    var isCrypto: Bool = false
    let yesterdaysDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    let formatter = DateFormatter()
    var finalAmount = 0.0
    var datePicker: UIDatePicker?
    var fadeOut = NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION
    var numFormatter = NumberFormatter()
    let kWarningTitle = "Something went wrong."
    let kWarningSubtitle = "Verify the date & symbol entered and try again."

    // MARK: - IBOutlets
    @IBOutlet var amountHadInvestedLabel: UILabel!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var finalAmountLabel: UILabel!
    @IBOutlet var addRegretButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        addRegretButton.layer.cornerRadius = 4
        numFormatter.numberStyle = .currency
        numFormatter.maximumFractionDigits = 2;
        fetchData()
    }

    func removeAnimationAndWarn() {
        DispatchQueue.main.async {
            _ = SCLAlertView().showWarning(self.kWarningTitle, subTitle: self.kWarningSubtitle)
            self.navigationController?.popViewController(animated: true)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(self.fadeOut)
        }
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
                guard let cryptoData = cryptoData else {
                    self.removeAnimationAndWarn()
                    return
                }
                if !cryptoData.cryptoDaily.keys.contains(chosenDate) {
                    self.removeAnimationAndWarn()
                    return
                }
                guard let currentPrice = cryptoData.cryptoDaily[yesterdayAsString]?["1a. open (USD)"],
                    let chosenDateClosePrice = cryptoData.cryptoDaily[chosenDate]?["4a. close (USD)"],
                    let amount = Double(amount),
                    let closePriceAsDouble = Double(chosenDateClosePrice),
                    let currentPriceAsDouble = Double(currentPrice) else {

                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(self.fadeOut)
                        }
                        return
                }

                let currencyPurchased = amount / closePriceAsDouble
                DispatchQueue.main.async {
                    if currentPriceAsDouble * currencyPurchased < amount {
                        finalAmountLabel.textColor = .red
                    }
                    finalAmountLabel.text = self.numFormatter.string(from: NSNumber(value: currentPriceAsDouble * currencyPurchased))
                    amountHadInvestedLabel.text = self.numFormatter.string(from: NSNumber(value: amount))
                    symbolLabel.text = symbol.uppercased()
                    dateLabel.text = chosenDate
                }
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(self.fadeOut)
            }
        } else {
            apiController.getStockDataForSpecifiedDate(with: symbol, date: datePicker.date) { (stockData) in
                guard let stockData = stockData else {
                    self.removeAnimationAndWarn()
                    return
                }

                self.apiController.getStockDataForToday(with: symbol, completion: { (todayStockData) in
                    self.todaysPrice = todayStockData

                    guard let amount = Double(amount),
                        let todaysPrice = self.todaysPrice else {
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(self.fadeOut)
                            }
                            return
                    }

                    let closePriceAsDouble = Double(stockData.adjClose)
                    let currentPriceAsDouble = Double(todaysPrice.adjClose)
                    let stockPurchased = amount / closePriceAsDouble
                    self.finalAmount = currentPriceAsDouble * stockPurchased

                    DispatchQueue.main.async {
                        if currentPriceAsDouble * stockPurchased < amount {
                            finalAmountLabel.textColor = .red
                        }
                        finalAmountLabel.text = self.numFormatter.string(from: NSNumber(value: currentPriceAsDouble * stockPurchased))
                        amountHadInvestedLabel.text = self.numFormatter.string(from: NSNumber(value: amount))
                        symbolLabel.text = symbol.uppercased()
                        dateLabel.text = chosenDate
                    }
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating(self.fadeOut)
                })
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
