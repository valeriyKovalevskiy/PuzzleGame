//
//  Options.swift


import Foundation

private let kCurrentGameSettingsKey = "currentGameSettingsKey"
private let kGameScoreKey = "gameScoreKey"

class Options {
    static let sharedOptions = Options()
    
    var currentGameSettingsIndex = 0 {
        didSet {
            UserDefaults.standard.set(currentGameSettingsIndex, forKey: kCurrentGameSettingsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var currentGameSettings: GameSettings {
        return allGameSettings[currentGameSettingsIndex]
    }
    
    var allGameSettings = [GameSettings]()
    
    
    var score = 0 {
        didSet {
            UserDefaults.standard.set(score, forKey: kGameScoreKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    init() {
        currentGameSettingsIndex = UserDefaults.standard.integer(forKey: kCurrentGameSettingsKey)
        score = UserDefaults.standard.integer(forKey: kGameScoreKey)

        let gameSettings3x3 = GameSettings(size: 3, timer: 1*60, shuffleNumber: 5)
        let gameSettings4x4 = GameSettings(size: 4, timer: 2*60, shuffleNumber: 10)
        let gameSettings5x5 = GameSettings(size: 5, timer: 4*60, shuffleNumber: 15)
        let gameSettings6x6 = GameSettings(size: 6, timer: 6*60, shuffleNumber: 20)
        
        allGameSettings = [gameSettings3x3, gameSettings4x4, gameSettings5x5, gameSettings6x6]
    }
}
