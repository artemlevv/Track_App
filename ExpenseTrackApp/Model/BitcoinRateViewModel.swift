//
//  BitcoinRateViewModel.swift
//  ExpenseTrackApp
//
//  Created by ARTEM on 05.03.2024.
//

import Foundation

class BitcoinRateViewModel{
    private var coreDataService: CoreDataService
    
    init(coreDataService: CoreDataService){
        self.coreDataService = coreDataService
    }
    
    // Requset for bitcoin rate data
    func getBitcoinRate(){
        guard shouldUpdateBitcoinRate() else{ return }
        
        Task{ [weak self] in
            do{
                let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let rate = try jsonDecoder.decode(BitcoinCurrency.self, from: data).bpi.USD.rate
                self?.coreDataService.updateBitcoinRate(rate: rate)
            } catch {
                print(error)
            }
        }
    }
    
    private func shouldUpdateBitcoinRate() -> Bool {
        guard let lastUpdateTime = self.coreDataService.bitcoinRate?.lastTimeUpdate else {
            // If never updated before, update now
            return true
        }
        // Checking if an hour has elapsed since the last update
        let currentTime = Date()
        let elapsedSeconds = currentTime.timeIntervalSince(lastUpdateTime)
        let oneHourInSeconds: TimeInterval = 60 * 60
        return elapsedSeconds >= oneHourInSeconds
    }
}
