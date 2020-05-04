//
//  ViewController.swift


import UIKit
import GameKit
import FacebookCore

class MenuViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var soundButton: UIButton!
    @IBOutlet private weak var vibrationButton: UIButton!

    //MARK: - Properties
    var isAuthenticated: Bool? {
        didSet {
            if isAuthenticated != oldValue, isAuthenticated == true {
                UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
                UserDefaults.standard.synchronize()
            }
        }
    }
    var firstLoad = true

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        isAuthenticated = UserDefaults.standard.object(forKey: "isAuthenticated") as? Bool
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            firstLoad = false
            authPlayerOnStart(true) { (success) in }
        }
    }
    
    //MARK: - Private methods
    private func reportScore() {
		print("reportScore")
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
    
    //MARK: - Actions
    @IBAction func statisticButtonPressed(_ sender: UIButton) {
        reportScore()
    }
    
    @IBAction func soundButtonPressed(_ sender: UIButton) {
        soundButton.isSelected = !sender.isSelected
        Settings.shared.sound = !soundButton.isSelected
    }
    
    @IBAction func vibrationButtonPressed(_ sender: UIButton) {
        vibrationButton.isSelected = !sender.isSelected
        Settings.shared.vibrationParams = !vibrationButton.isSelected
    }
}

extension MenuViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
