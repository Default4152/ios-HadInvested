//
//  RegretsTableViewController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import SCLAlertView
import FirebaseAuth

class RegretsTableViewController: UITableViewController {
    private var filteredRegrets: [Regret] = [] {
        didSet {
            let restorationId = self.restorationIdentifier
            if restorationId == "PublicRegretsStoryboard" {
                filteredRegrets = filteredRegrets.filter { $0.isPublic }
            } else {
                filteredRegrets = filteredRegrets.filter { $0.userID == Auth.auth().currentUser?.uid }
            }
        }
    }
    private let dateFormatter = DateFormatter()
    private let apiController = APIController()

    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        apiController.getRegretsFromFirebase { (error, regrets) in
            if let error = error {
                NSLog("Error fetching from table view: \(error)")
            }

            guard var regrets = regrets else { return }
            
            regrets = regrets.sorted(by: {
                guard let dateOne = self.dateFormatter.date(from: $0.dateOfRegret),
                    let dateTwo = self.dateFormatter.date(from: $1.dateOfRegret) else { return false }
                return dateOne < dateTwo
            })
            
            self.filteredRegrets = regrets

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRegrets.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let regret = filteredRegrets[indexPath.row]
        generatePopupDetail(regret: regret)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegretCell", for: indexPath) as! RegretTableViewCell
        cell.parentRestorationIdentifier = self.restorationIdentifier
        cell.regret = filteredRegrets[indexPath.row]
        return cell
    }

    // MARK: - Private
    private func generatePopupDetail(regret: Regret) {
        let screenSize = UIScreen.main.bounds
        let boldAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        let normalAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .regular)]

        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenSize.width - 45.0,
            kWindowHeight: screenSize.height * 0.30
        )

        let alertView = SCLAlertView(appearance: appearance)
        let subview = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenSize.width - 45.0, height: screenSize.height * 0.30))

        let stockLabel = UILabel(frame: CGRect(x: 16.0, y: 10, width: screenSize.width - 100.0, height: 25))
        let stockLabelText = NSMutableAttributedString(string: "Stock", attributes: boldAttribute)
        let stockLabelNormalText = NSMutableAttributedString(string: ": \(regret.stock)", attributes: normalAttribute)
        stockLabelText.append(stockLabelNormalText)
        stockLabel.attributedText = stockLabelText
        stockLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(stockLabel)

        let authorLabel = UILabel(frame: CGRect(x: 16.0, y: stockLabel.frame.maxY + 7.0, width: screenSize.width - 100.0, height: 25.0))
        let authorLabelText = NSMutableAttributedString(string: "Author", attributes: boldAttribute)
        let authorLabelNormalText = NSMutableAttributedString(string: ": \(regret.author)", attributes: normalAttribute)
        authorLabelText.append(authorLabelNormalText)
        authorLabel.attributedText = authorLabelText
        authorLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(authorLabel)

        let amountEnteredLabel = UILabel(frame: CGRect(x: 16.0, y: authorLabel.frame.maxY + 7.0, width: screenSize.width - 100.0, height: 25.0))
        let amountEnteredLabelText = NSMutableAttributedString(string: "Amount", attributes: boldAttribute)
        let amountEnteredLabelNormalText = NSMutableAttributedString(string: ": $\(regret.amount)", attributes: normalAttribute)
        amountEnteredLabelText.append(amountEnteredLabelNormalText)
        amountEnteredLabel.attributedText = amountEnteredLabelText
        amountEnteredLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(amountEnteredLabel)

        let calculatedAmountLabel = UILabel(frame: CGRect(x: 16.0, y: amountEnteredLabel.frame.maxY + 7.0, width: screenSize.width - 100.0, height: 25.0))
        let calculatedAmountLabelText = NSMutableAttributedString(string: "Would have made", attributes: boldAttribute)
        let calculatedAmountLabelNormalText = NSMutableAttributedString(string: ": $\(regret.finalAmount.rounded(toPlaces: 2))", attributes: normalAttribute)
        calculatedAmountLabelText.append(calculatedAmountLabelNormalText)
        calculatedAmountLabel.attributedText = calculatedAmountLabelText
        calculatedAmountLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(calculatedAmountLabel)

        let dateChosenLabel = UILabel(frame: CGRect(x: 16.0, y: calculatedAmountLabel.frame.maxY + 7.0, width: screenSize.width - 100.0, height: 25.0))
        let dateChosenLabelText = NSMutableAttributedString(string: "Date Chosen", attributes: boldAttribute)
        let dateChosenLabelNormalText = NSMutableAttributedString(string: ": \(regret.dateCalculated)", attributes: normalAttribute)
        dateChosenLabelText.append(dateChosenLabelNormalText)
        dateChosenLabel.attributedText = dateChosenLabelText
        dateChosenLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(dateChosenLabel)

        let userIdLabel = UILabel(frame: CGRect(x: 16.0, y: dateChosenLabel.frame.maxY + 7.0, width: screenSize.width - 100.0, height: 25.0))
        let userIdLabelText = NSMutableAttributedString(string: "UID", attributes: boldAttribute)
        let userIdLabelNormalText = NSMutableAttributedString(string: ": \(regret.userID)", attributes: normalAttribute)
        userIdLabelText.append(userIdLabelNormalText)
        userIdLabel.attributedText = userIdLabelText
        userIdLabel.textAlignment = NSTextAlignment.left
        subview.addSubview(userIdLabel)

        alertView.customSubview = subview
        
        let regretDateFormatter = DateFormatter()
        regretDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let dateOfRegret = regretDateFormatter.date(from: regret.dateOfRegret) {
            let dateAsString = dateFormatter.string(from: dateOfRegret)
            alertView.showInfo(dateAsString, subTitle: "")
        }
    }
}

extension RegretsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        let filtered = apiController.regrets.filter({ $0.stock.lowercased().contains(searchText) || $0.dateOfRegret.lowercased().contains(searchText) })
        
        self.filteredRegrets = filtered.isEmpty ? apiController.regrets : filtered
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
