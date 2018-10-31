//
//  DoubleRoundExtension.swift
//  HadInvested
//
//  Created by Conner on 10/31/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
