//
//  GameViewModel.swift
//  SlotMachine
//
//  Created by Denis Kuzmin on 16.02.2022.
//

import Foundation
import Combine
import CombineCocoa

class GameViewModel {
    
    let slotChangeInterval = 0.2
    var slot: AnyPublisher<[String], Never>?
    var labels: AnyPublisher<(String, String), Never>?
    var subscriptions = Set<AnyCancellable>()
    
    init(buttonPressed: AnyPublisher<Void, Never>) {
       
        let slotValues = ["🦖", "🦕","🐫", "🐖", "🐳", "🐙"]
        
        let gameInProgress = CurrentValueSubject<Bool, Never>(false)
        
        let gameState = buttonPressed
            .map { value -> Bool in
                gameInProgress.value.toggle()
                return gameInProgress.value
            }
            .share()
        
        let slot = Timer.publish(every: slotChangeInterval, on: RunLoop.main, in: .common)
            .autoconnect()
            .map { _ -> [String] in

                return [slotValues[Int.random(in: (0...5))],
                        slotValues[Int.random(in: (0...5))],
                        slotValues[Int.random(in: (0...5))]]
            }
            .combineLatest(gameState)
            .filter { $0.1 }
            .map { value -> ([String], Bool) in
                let isEqualSlots = value.0[0] == value.0[1] && value.0[1] == value.0[2]
                let result = value.1 && isEqualSlots
                return (value.0, result)
            }
            .setFailureType(to: Never.self)
            .share()
        
        self.labels = gameState
            .combineLatest(slot.map { $0.1 } )
            .map {
                switch $0.0 {
                case true:
                    return ("Stop Game", "Let's check your luck")
                case false:
                    if $0.1 {
                        return ("Start Game", "Congratulations! You won!!!")
                    } else {
                        return ("Start Game", "Sorry. Not this time!")
                    }
                }
            }
            .eraseToAnyPublisher()
            
        self.slot = slot.map { $0.0 }.eraseToAnyPublisher()
    }
}
