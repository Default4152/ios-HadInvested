//
//  APIController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation
import FirebaseAuth

class APIController {
    private let firebaseURL = URL(string: "https://hadinvested.firebaseio.com/")!
    private let formatter = DateFormatter()
    var regrets: [Regret] = []

    func getStockDataForSpecifiedDate(with stock: String, date: String, completion: @escaping (StockData?) -> Void) {
        formatter.dateFormat = "yyyy-MM-dd"
        let url: URL!
        let today = Date()
        
        if (date == formatter.string(from: today)) {
            // The passed in date is today, use a different request URL
            url = URL(string: "https://api.intrinio.com/prices?identifier=\(stock.uppercased())&start_date=\(formatter.string(from: today.dayBefore.dayBefore.dayBefore))&end_date=\(date)&frequency=daily&api_key=OjRjOTYyMDFiYzc4MWUzNDgxMmRiMjM0NTFhMjQ2Zjc2")!
        } else {
            url = URL(string: "https://api.intrinio.com/prices?identifier=\(stock.uppercased())&start_date=\(date)&end_date=\(date)&frequency=daily&api_key=OjRjOTYyMDFiYzc4MWUzNDgxMmRiMjM0NTFhMjQ2Zjc2")!
        }

        let urlSession = URLSession.shared
        let stockDataURL = URLRequest(url: url)

        urlSession.dataTask(with: stockDataURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(nil)
                return
            }
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let stockData = try decoder.decode(Quotes.self, from: data)
                if (stockData.resultCount == 0) {
                    completion(nil)
                    return
                }
                completion(stockData.data[0])
            } catch {
                NSLog("Error decoding data: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func getRegretsFromFirebase(completion: @escaping (Error?, [Regret]?) -> Void) {
        let url = firebaseURL.appendingPathExtension("json")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error with getting regrets: \(error)")
                completion(error, nil)
                return
            }

            guard let data = data else {
                NSLog("No data returned from firebase")
                completion(nil, nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let regretsJSON = try decoder.decode(RegretPosts.self, from: data)
                self.regrets = regretsJSON.regrets.values.compactMap { $0 }
            } catch let error {
                NSLog("Error decoding data: \(error)")
            }

            completion(nil, self.regrets)
        }.resume()
    }
}
