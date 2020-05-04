//
//  GameOverViewController.swift

import UIKit
import GameKit
import StoreKit

protocol GameOverViewControllerDelegate: class {
    func gameOverViewControllerDidTapMenu()
    func gameOverViewControllerDidTapRestart()
}

class GameOverViewController: UIViewController {
    
    @IBOutlet var currentScoreLabel: UILabel!
    @IBOutlet var oldScoreLabel: UILabel!
    
    var currentScore: Int = 0
    var oldScore: Int = 0
    var isAuthenticated: Bool? {
        didSet {
            if isAuthenticated != oldValue, isAuthenticated == true {
                UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    weak var delegate: GameOverViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentScoreLabel.text = "\(currentScore)"
        self.oldScoreLabel.text = "\(oldScore)"
    }
    
    private func reportScore() {
        authPlayerOnStart(false) { (success) in
            if success {
                self.reportScoreAndShowLeaderBoard()
            }
        }
    }
    
    private func authPlayerOnStart(_ onStart: Bool, block: @escaping (_ success: Bool) -> ()) {
        if onStart, isAuthenticated != true {
            block(false)
            return
        }
        if !onStart, isAuthenticated == true {
            block(true)
            return
        }
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (controller, error) in
            if let currentController = controller {
                self.present(currentController, animated: true, completion: nil)
            } else {
                self.isAuthenticated = error == nil ? localPlayer.isAuthenticated : false
                block(localPlayer.isAuthenticated)
            }
        }
    }
    
    private func reportScoreAndShowLeaderBoard() {
        let scoreReporter = GKScore(leaderboardIdentifier: kLeaderBoardId)
        scoreReporter.value = Int64(Options.sharedOptions.score)
        
        let scoreArray = [scoreReporter]
        GKScore.report(scoreArray, withCompletionHandler: nil)
        
        showGameCenterVC()
    }
    
    private func showGameCenterVC() {
        let gameCenterVC = GKGameCenterViewController()
        gameCenterVC.gameCenterDelegate = self
        
        present(gameCenterVC, animated: true, completion: nil)
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.dismiss(animated:true) {
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            self.delegate?.gameOverViewControllerDidTapRestart()
        }
    }
    
    @IBAction func didTappedLeadersButton(_ sender: UIButton) {
        
        reportScore()
    }
    
    @IBAction func didTappedShareButton(_ sender: UIButton) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        self.dismiss(animated:false) {
            SKTAudio.sharedInstance().pauseBackgroundMusic()
            self.delegate?.gameOverViewControllerDidTapMenu()
        }
    }
}

extension GameOverViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
