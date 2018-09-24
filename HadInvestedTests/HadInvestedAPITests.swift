//
//  HadInvestedAPITests.swift
//  HadInvestedTests
//
//  Created by Conner on 9/24/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import XCTest
@testable import HadInvested

class HadInvestedAPITests: XCTestCase {
    
    func testAPIGetStockData() {
        let apiController = APIController()
        let expectation = self.expectation(description: "Retrieves Stock Data")
        
        apiController.getStockData(with: "AAPL") { (stockData) in
            guard let stockData = stockData else { return }
            XCTAssertNotNil(stockData)
            XCTAssertEqual(stockData.timeSeriesDaily["2018-08-13"]?.close, "208.8700")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testAPIGetCryptoData() {
        let apiController = APIController()
        let expectation = self.expectation(description: "Retrieves Crypto Data")
        
        apiController.getCryptoData(with: "BTC") { (cryptoData) in
            guard let cryptoData = cryptoData else { return }
            XCTAssertNotNil(cryptoData)
            XCTAssertEqual(cryptoData.cryptoDaily["2018-08-13"]?["4a. close (USD)"], "6274.76760680")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }

}
