//
//  Regret.swift
//  HadInvested
//
//  Created by Conner on 9/25/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

typealias Regrets = [String: Regret]

struct Regret: Codable, Equatable {
    init(dateOfRegret: String, stockSymbol: String, identifier: String = UUID().uuidString) {
        self.dateOfRegret = dateOfRegret
        self.stockSymbol = stockSymbol
        self.identifier = identifier
    }
    let dateOfRegret, stockSymbol, identifier: String
}
