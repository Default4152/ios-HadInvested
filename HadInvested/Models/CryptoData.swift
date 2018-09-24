//
//  CryptoData.swift
//  HadInvested
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

struct CryptoData: Codable {
    let cryptoDaily: [String: [String: String]]
    
    enum CodingKeys: String, CodingKey {
        case cryptoDaily = "Time Series (Digital Currency Daily)"
    }
}
