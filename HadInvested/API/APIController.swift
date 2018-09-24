//
//  APIController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

class APIController {
    private func getData(with url: String, withType choiceType: String) {
        let urlSession = URLSession.shared
        let dataURL = URLRequest(url: URL(string: url)!)

        urlSession.dataTask(with: dataURL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching data: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                if choiceType == "cryptocurrency" {
                    let cryptoData = try decoder.decode(CryptoData.self, from: data)
                    print(cryptoData.cryptoDaily["2018-08-13"]?["4a. close (USD)"])
                } else {
                    let stockData = try decoder.decode(StockData.self, from: data)
                    print(stockData.timeSeriesDaily["2018-08-13"]?.close)
                    print(stockData.timeSeriesDaily["1998-08-12"]?.close)
                }
            } catch {
                NSLog("Error decoding data: \(error)")
            }
        }.resume()
    }
    public func getStockData(for symbol: String, completion: @escaping (Error?) -> Void) {
        let url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&outputsize=full&apikey=SEBO6A22C8K8OE0T"
        getData(with: url, withType: "stock")
    }
    public func getCryptoData(for crypto: String, completion: @escaping (Error?) -> Void) {
        let url = "https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY&symbol=\(crypto)&market=USD&apikey=SEBO6A22C8K8OE0T"
        getData(with: url, withType: "cryptocurrency")
    }
}
