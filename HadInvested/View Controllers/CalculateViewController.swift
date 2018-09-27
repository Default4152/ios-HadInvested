//
//  CalculateViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CalculateViewController: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate {
    let activityData = ActivityData(size: nil,
                                    message: "Calculating...",
                                    messageFont: nil,
                                    messageSpacing: nil,
                                    type: .squareSpin,
                                    color: nil,
                                    padding: nil,
                                    displayTimeThreshold: nil,
                                    minimumDisplayTime: 2,
                                    backgroundColor: UIColor(red: 0.00, green: 0.48, blue: 1.00, alpha: 1.0),
                                    textColor: nil)
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var isCrypto: UISwitch!
    @IBOutlet var calculateButton: UIButton!
    
    override func viewDidLoad() {
        amountTextField.delegate = self
        calculateButton.layer.cornerRadius = 4
        datePicker.maximumDate = Date()
        backButton.tintColor = .white
    }
    
    @IBAction func calculate(_ sender: Any) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let symbol = symbolTextField.text,
            let amount = amountTextField.text else { return }
        if segue.identifier == "ShowCalculationSegue" {
            if let calculatedVC = segue.destination as? CalculateResultViewController {
                calculatedVC.amount = amount
                calculatedVC.symbol = symbol
                calculatedVC.isCrypto = isCrypto.isOn
                calculatedVC.datePicker = datePicker
            }
        }
    }
}
