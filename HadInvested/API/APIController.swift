//
//  APIController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

class APIController {
    func getStockData(with stock: String, completion: @escaping (StockData?) -> Void) {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(stock)&outputsize=full&apikey=SEBO6A22C8K8OE0T")!

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
                let stockData = try decoder.decode(StockData.self, from: data)
                completion(stockData)
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
}
