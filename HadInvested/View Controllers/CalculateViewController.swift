//
//  CalculateViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import DayDatePicker

class CalculateViewController: UIViewController, NVActivityIndicatorViewable, UITextFieldDelegate, DayDatePickerViewDelegate {

    var chosenDate: String?
    let activityData = ActivityData(size: nil,
                                    message: "Calculating...",
                                    messageFont: nil,
                                    messageSpacing: nil,
                                    type: .squareSpin,
                                    color: nil,
                                    padding: nil,
                                    displayTimeThreshold: nil,
                                    minimumDisplayTime: 2,
                                    backgroundColor: UIColor(red: 34.0 / 255.0, green: 91.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0),
                                    textColor: nil)
    
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var symbolTextField: UITextField!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var calculateButton: UIButton!
    @IBOutlet var datePicker: DayDatePickerView!
    
    override func viewDidLoad() {
        datePicker.delegate = self
        datePicker.setMaxDate(Date(), animated: true)
        datePicker.setFeedback(hasHapticFeedback: false, hasSound: false)
        datePicker.overlayView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 0.4452054795)
        amountTextField.delegate = self
        symbolTextField.delegate = self
        calculateButton.layer.cornerRadius = 4
        backButton.tintColor = .white
    }
    
    func didSelectDate(day: NSInteger, month: NSInteger, year: NSInteger) {
        chosenDate = String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    @IBAction func calculate(_ sender: Any) {
        guard let symbolTextFieldText = symbolTextField.text, !symbolTextFieldText.isEmpty,
            let amountTextFieldText = amountTextField.text, !amountTextFieldText.isEmpty else { return }
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let symbol = symbolTextField.text, !symbol.isEmpty,
            let amount = amountTextField.text, !amount.isEmpty else { return }
        if segue.identifier == "ShowCalculationSegue" {
            if let calculatedVC = segue.destination as? CalculateResultViewController {
                calculatedVC.amount = amount
                calculatedVC.symbol = symbol
                calculatedVC.chosenDate = chosenDate
            }
        }
    }
}
