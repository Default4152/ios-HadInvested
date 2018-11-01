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
import Firebase
import FirebaseAuth
import DayDatePicker

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
    var chosenDate: String?
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
    @IBOutlet var isPublicRegretSwitch: UISwitch!
    
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
            let chosenDate = chosenDate else { return }
        
        apiController.getStockDataForSpecifiedDate(with: symbol, date: chosenDate) { (stockData) in
            guard let stockData = stockData else {
                self.removeAnimationAndWarn()
                return
            }
            
            self.apiController.getStockDataForSpecifiedDate(with: symbol, date: self.formatter.string(from: Date()), completion: { (todayStockData) in
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
    
    @IBAction func addRegret(_ sender: Any) {
        guard let symbol = symbol,
            let amount = amount else { return }
        
        let uid = Auth.auth().currentUser?.uid // Get User ID to create regret post in Firebase
        let ref = Database.database().reference()
        let key = ref.child("regrets").childByAutoId().key // Specific string for only 1 post, Random key for this particular regret "post"
        
        let isPublicRegret = isPublicRegretSwitch.isOn
        
        let regretDict = ["userID": uid as Any,
                          "dateOfRegret": formatter.string(from: Date()),
                          "author": Auth.auth().currentUser?.displayName as Any,
                          "stock": symbol.uppercased(),
                          "amount": amount,
                          "finalAmount": finalAmount,
                          "dateCalculated": chosenDate as Any,
                          "isPublic": isPublicRegret] as [String : Any]
        
        let regretPost = ["\(key!)": regretDict]
        ref.child("regrets").updateChildValues(regretPost) // updateChildValues, don't replace
        
        navigationController?.popViewController(animated: true)
    }
}
