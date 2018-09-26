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
    
    func getStockData(with stock: String, completion: @escaping (StockData?) -> Void) {
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=\(stock)&outputsize=full&apikey=SEBO6A22C8K8OE0T")!

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
    
    func getRegretsFromFirebase(completion: @escaping (Error?) -> Void) {
        let url = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error with getting regrets: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from firebase")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let regrets = try decoder.decode(Regrets.self, from: data)
                print(regrets)
            } catch let error {
                NSLog("Error decoding data: \(error)")
            }
        }.resume()
    }
    
}
