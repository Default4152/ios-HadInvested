//
//  Regret.swift
//  HadInvested
//
//  Created by Conner on 9/25/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

struct RegretPosts: Codable {
    let regrets: [String: Regret]
}

struct Regret: Codable {
    let amount, author, dateCalculated, dateOfRegret: String
    let finalAmount: Double
    let stock, userID: String
}
