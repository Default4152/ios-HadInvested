//
//  APIController.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

class APIController {
    private let firebaseURL = URL(string: "https://hadinvested.firebaseio.com/")!
    let formatter = DateFormatter()
    
    func getStockDataForSpecifiedDate(with stock: String, date: Date, completion: @escaping (StockData?) -> Void) {
        formatter.dateFormat = "dd-MM-yyyy"
        
        let chosenDate = formatter.string(from: date)
        let url = URL(string: "https://api.intrinio.com/prices?identifier=\(stock)&start_date=\(chosenDate)&end_date=\(chosenDate)&frequency=daily&api_key=OjRjOTYyMDFiYzc4MWUzNDgxMmRiMjM0NTFhMjQ2Zjc2")!
        
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
    
    func getStockDataForToday(with stock: String, completion: @escaping (StockData?) -> Void) {
        formatter.dateFormat = "dd-MM-yyyy"
        let today = formatter.string(from: Date())
        let url = URL(string: "https://api.intrinio.com/prices?identifier=\(stock)&start_date=\(today)&end_date=\(today)&frequency=daily&api_key=OjRjOTYyMDFiYzc4MWUzNDgxMmRiMjM0NTFhMjQ2Zjc2")!
        
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

    func putRegretToFirebase(with regret: Regret, completion: @escaping (Error?) -> Void) {
        let identifier = regret.identifier
        let url = firebaseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"

        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(regret)
        } catch {
            NSLog("Error with encoding regret: \(error)")
        }

        URLSession.shared.dataTask(with: urlRequest) { (_, _, error) in
            if let error = error {
                NSLog("Error with PUTting regret: \(error)")
                completion(error)
                return
            }

            completion(nil)
        }.resume()
    }

    func getRegretsFromFirebase(completion: @escaping (Error?, [Regret]?) -> Void) {
        let url = firebaseURL.appendingPathExtension("json")
        var regrets: [Regret] = []
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
                let regretsJSON = try decoder.decode(Regrets.self, from: data).values
                regrets = regretsJSON.compactMap { $0 }
            } catch let error {
                NSLog("Error decoding data: \(error)")
            }

            completion(nil, regrets)
        }.resume()
    }
}
