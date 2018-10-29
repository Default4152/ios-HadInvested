//
//  StockData.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

struct Quotes: Codable {
    let data: [StockData]
    let resultCount: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case resultCount = "result_count"
    }
}

struct StockData: Codable {
    let date: String
    let adjOpen, adjClose: Double
    
    enum CodingKeys: String, CodingKey {
        case date
        case adjOpen = "adj_open"
        case adjClose = "adj_close"
    }
}
