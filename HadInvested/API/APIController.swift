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
    var regrets: [Regret] = []
    
    func getStockDataForSpecifiedDate(with stock: String, date: String, completion: @escaping (StockData?) -> Void) {
        let url = URL(string: "https://api.intrinio.com/prices?identifier=\(stock.uppercased())&start_date=\(date)&end_date=\(date)&frequency=daily&api_key=OjRjOTYyMDFiYzc4MWUzNDgxMmRiMjM0NTFhMjQ2Zjc2")!
        
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
    
    func getCryptoData(with crypto: String, completion: @escaping (CryptoData?) -> Void) {
        let url = URL(string: "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY&symbol=\(crypto)&market=USD&apikey=SEBO6A22C8K8OE0T")!

        let urlSession = URLSession.shared
        let cryptoDataURL = URLRequest(url: url)

        urlSession.dataTask(with: cryptoDataURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                completion(nil)
                return
            }

            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let cryptoData = try decoder.decode(CryptoData.self, from: data)
                completion(cryptoData)
            } catch {
                NSLog("Error decoding crypto data: \(error)")
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
                self.regrets = regretsJSON.regrets.filter { $0.value.userID == Auth.auth().currentUser?.uid }.values.compactMap { $0 }
            } catch let error {
                NSLog("Error decoding data: \(error)")
            }

            completion(nil, self.regrets)
        }.resume()
    }
}
