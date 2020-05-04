//
//  GameSettings.swift

import Foundation

enum GameResult: Int {
    case veryBad = 0
    case bad = 1
    case normal = 2
    case good = 3
}

enum TimeResult {
    case veryBad
    case bad
    case normal
    case good
}

enum FlipsCountResult {
    case veryBad
    case bad
    case normal
    case good
}

struct GameSettings {
    let size: Int
    let timer: Int
    let shuffleNumber: Int

    
//    func scoreForGameResult(_ gameResult: GameResult) -> Int {
//        return 0
//    }

}
