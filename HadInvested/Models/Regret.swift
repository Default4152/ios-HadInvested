//
//  Regret.swift
//  HadInvested
//
//  Created by Conner on 9/25/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

struct Regrets: Codable {
    let regrets: [String: Regret]
    
    enum CodingKeys: String, CodingKey {
        case regrets = "Regrets"
    }
}

struct Regret: Codable, Equatable {
    init(dateOfRegret: String, stockSymbol: String) {
        self.dateOfRegret = dateOfRegret
        self.stockSymbol = stockSymbol
    }
    
    let dateOfRegret, stockSymbol: String
}
