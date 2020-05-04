//
//  ViewController.swift


import UIKit
import PureLayout
import GoogleMobileAds

var numberOfRows = 3
var numberOfColumns = 3

let kGameOverSegue = "kGameOverSegue"

class GameView : UIView {
    
    var containerView : UIView?
    var controller : GameViewController?
}

class GameSquareView : UIImageView {
    var label: UILabel
    var value: Int?
    var empty: Bool {
        get {
            return self.empty
        }
        set(newEmpty) {
            if (newEmpty == true) {
                self.layer.borderWidth = 0.0
            } else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    override init(image: UIImage?) {
        self.label = UILabel()
        super.init(image: image)
        self.empty = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.label = UILabel()
        super.init(coder: aDecoder)
        self.empty = false
    }
    
    func setValue(_ value:Int) {
        self.value = value
        self.label.text = "\(value)"
        self.label.sizeToFit()
        self.label.frame = CGRect(x: self.bounds.size.width / 2.0 - self.label.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0 - self.label.bounds.size.height / 2.0, width: self.label.bounds.size.width, height: self.label.bounds.size.height)
    }
}

class GameViewController: UIViewController {
    
    @IBOutlet private weak var boardView: UIView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var levelController: LevelController!
	
	var bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
    
    private var timer: Timer?
    private var startTimerInterval: TimeInterval = 0.0
    private var levelsPassed: Int = 0
    private var matrix = Array<Array<GameSquareView>>()
    private var emptySpot = (numberOfRows - 1, numberOfColumns - 1)
    private var middleView : UIView?
    private var showingTitleNumbers = false
    var level = 1
    var currentProgress: Int = 0

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startGame()

        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipe(_:)))
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.left;
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipe(_:)))
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.right;
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipe(_:)))
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.up;
        self.view.addGestureRecognizer(swipeUpGestureRecognizer)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.swipe(_:)))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.down;
		self.view.addGestureRecognizer(swipeDownGestureRecognizer)
		
		setupAdmobBanner(bannerView)
    }
	
    //MARK: - Private methods
    private func startGame() {
        levelsPassed = 0
        currentProgress = levelsPassed
        updateCount()
        startTimer()
        startNewGame()
    }
    
    private func startNewGame() {
        updateCount()
        updateLevel()
        let currentGameSettings = Options.sharedOptions.currentGameSettings
        numberOfRows = currentGameSettings.size
        numberOfColumns = currentGameSettings.size
        
        for x in 0 ..< matrix.count {
            for y in 0 ..< matrix[x].count {
                matrix[x][y].removeFromSuperview()
            }
        }
        
        matrix = Array<Array<GameSquareView>>()
        
        let random = arc4random() % 10 + 1
        let imageName = "image_\(random)"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        let landscape = UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
        if landscape {
            imageView.bounds = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.height, height: self.boardView.bounds.size.height)
            imageView.frame = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.height, height: self.boardView.bounds.size.height)
        } else {
            imageView.bounds = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.width, height: self.boardView.bounds.size.width)
            imageView.frame = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.width, height: self.boardView.bounds.size.width)
        }
        
        self.view.addSubview(imageView)
        
        if middleView != nil {
            middleView!.removeFromSuperview()
        }
        self.middleView = UIView()
        self.middleView!.layer.borderColor = UIColor.white.cgColor
        self.middleView!.layer.borderWidth = 1.0
        if  landscape {
            self.middleView!.frame = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.height, height: self.boardView.bounds.size.height)
        } else {
            self.middleView!.frame = CGRect(x: 0, y: 0, width: self.boardView.bounds.size.width, height: self.boardView.bounds.size.width)
        }
        
        self.boardView.addSubview(middleView!)
        let side = landscape ? self.boardView.bounds.size.height : self.boardView.bounds.size.width
        let width = side / CGFloat(numberOfColumns)
        let height = side / CGFloat(numberOfRows)
        
        for i in 0 ..< numberOfRows {
            
            var row = Array<GameSquareView>()
            
            for j in 0 ..< numberOfColumns {
                guard let image = image else { return }
                let w = image.size.width / CGFloat(numberOfColumns)
                let h = image.size.height / CGFloat(numberOfRows)
                let cgImage = image.cgImage?.cropping(to: CGRect(x: CGFloat(j) * w, y: CGFloat(i) * h, width: w, height: h))
                let newImage = UIImage(cgImage: cgImage!)
                let isEmpty = i == j && i == numberOfRows - 1
                let gameSquareView = GameSquareView(image: isEmpty ? nil : newImage)
                gameSquareView.frame = CGRect(x: CGFloat(j) * width + width / 2.0, y: CGFloat(i) * height + height / 2.0, width: 0, height: 0)
                UIView.animate(withDuration: 0.2, animations: {
                    gameSquareView.frame = CGRect(x: CGFloat(j) * width, y: CGFloat(i) * height, width: width, height: height)
                })
                self.middleView!.addSubview(gameSquareView)
                gameSquareView.alpha = 0
                
                if isEmpty {
                    gameSquareView.empty = true
                } else {
                    gameSquareView.setValue(i * numberOfColumns + j)
                    gameSquareView.label.alpha = self.showingTitleNumbers ? 1 : 0
                }
                
                row.append(gameSquareView)
            }
            
            matrix.append(row)
        }
        
        imageView.removeFromSuperview()
        
        for i in 0 ..< numberOfRows {
            for j in 0 ..< numberOfColumns {
                UIView.animate(withDuration: 0.2, animations: {
                    self.matrix[i][j].alpha = 1
                })
            }
        }
        
        emptySpot = (numberOfRows - 1, numberOfColumns - 1)
        
        while isFinished() == true {
            shuffle()
        }
    }
    
    private func shuffle() {
        let numberOfShuffles = Options.sharedOptions.currentGameSettings.shuffleNumber
        var position = randomAdjacentPosition(self.emptySpot.0, j: self.emptySpot.1)
        for _ in 0 ..< numberOfShuffles {
            swapEmptyWithI(position.0, j:position.1)
            position = randomAdjacentPosition(position.0, j: position.1)
        }
    }
    
    private func randomAdjacentPosition(_ i:Int, j:Int) -> (Int, Int) {
        let horizontal = arc4random() % 2
        if horizontal == 1 {
            let left = arc4random() % 2
            if left == 1 && i != 0 ||
                left == 0 && i == numberOfColumns - 1 {
                    return (i - 1, j)
            } else {
                return (i + 1, j)
            }
        } else {
            let up = arc4random() % 2
            if up == 1 && j != 0 ||
                up == 0 && j == numberOfRows - 1 {
                    return (i, j - 1)
            } else {
                return (i, j + 1)
            }
        }
    }
    
    private func swapEmptyWithI(_ i:Int, j:Int) {
        
        let landscape = UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
        let side = landscape ? self.boardView.bounds.size.height : self.boardView.bounds.size.width
        let width = side / CGFloat(numberOfColumns)
        let height = side / CGFloat(numberOfRows)
        let gameSquareView = self.matrix[i][j]
        let newJ = self.emptySpot.1
        let newI = self.emptySpot.0
        
        UIView.animate(withDuration: 0.2, animations: {
            gameSquareView.frame = CGRect(x: CGFloat(newJ) * width, y: CGFloat(newI) * height, width: width, height: height)
        })
        
        let emptySpotView = matrix[newI][newJ]
        
        emptySpotView.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, delay: 0.12, options: UIView.AnimationOptions(rawValue: 0), animations: {
            emptySpotView.alpha = 1.0
            }, completion: nil)
        
        emptySpotView.frame = CGRect(x: CGFloat(j) * width, y: CGFloat(i) * height, width: width, height: height)
        matrix[newI][newJ] = gameSquareView
        matrix[i][j] = emptySpotView
        self.emptySpot = (i, j)
    }
    
    private func isFinished() -> Bool {
        for i in 0 ..< numberOfRows {
            for j in 0 ..< numberOfColumns {
                if i == j && i == numberOfRows - 1 {
                    return true // empty square
                }
                let gameSquare = matrix[i][j]
                if gameSquare.value != i * numberOfColumns + j {
                    return false
                }
            }
        }
        return true
    }
    
    private func updateCount() {
        self.countLabel.text = "\(self.levelsPassed)"
    }
    
    private func updateLevel() {
        updateLevelLabels()
        checkLevelUpIsAvailable()
    }
        
    private func updateLevelMusic() {
        guard currentProgress % level == 0 else { return }
        let randomLevelMusic = arc4random() % 10 + 1
        SKTAudio.sharedInstance().playBackgroundMusic(filename: "Level_\(randomLevelMusic).mp3")
        startTimer()
    }
    
    private func updateLevelLabels() {
        levelController.leftLabel.text = "\(level)"
        levelController.rightLabel.text = "\(level + 1)"
        levelController.progress = Double(currentProgress) / Double(level)
        do {
            updateLevelMusic()
        }
    }
    
    private func checkLevelUpIsAvailable() {
        currentProgress = currentProgress + 1
        guard currentProgress / level == 1 else { return }
        level = level + 1
        currentProgress = 0
    }

    private func nextGame() {
        self.levelsPassed += 1
        startNewGame()
    }
    
    private func gameOver() {
        self.performSegue(withIdentifier: kGameOverSegue, sender: nil)
    }
    
    //MARK: - Obj c Methods
    @objc private func swipe(_ sender:AnyObject!) {
        let recognizer = sender as! UISwipeGestureRecognizer
        
        var i = self.emptySpot.0
        var j = self.emptySpot.1
        if recognizer.direction == UISwipeGestureRecognizer.Direction.left {
            j += 1
            if  j < numberOfRows {
                swapEmptyWithI(i, j: j)
            }
            print("left")
        } else if recognizer.direction == UISwipeGestureRecognizer.Direction.right {
            j -= 1
            if  j >= 0 {
                swapEmptyWithI(i, j: j)
            }
            print("right")
        } else if recognizer.direction == UISwipeGestureRecognizer.Direction.up {
            i += 1
            if  i < numberOfRows {
                swapEmptyWithI(i, j: j)
            }
            print("up")
        } else if recognizer.direction == UISwipeGestureRecognizer.Direction.down {
            i -= 1
            if  i >= 0 {
                swapEmptyWithI(i, j: j)
            }
            print("down")
        }
        if isFinished() {
            self.nextGame()
        }
    }
    
    //MARK: - Timer methods
    @objc private func update() {
        let timeOffset = Int(Date().timeIntervalSince1970 - self.startTimerInterval)
        let currentGameSettings = Options.sharedOptions.currentGameSettings
        let timeLeft = currentGameSettings.timer - timeOffset
        if timeLeft < 0 {
            self.timer?.invalidate()
            self.gameOver()
        } else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            let formattedString = formatter.string(from: TimeInterval(timeLeft))!
            self.timerLabel.text = formattedString
        }
		var some = 3
		if some > 10 {
			some += 1
		}
    }
    
    private func startTimer() {
        print("startTimer")
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.startTimerInterval = Date().timeIntervalSince1970
        self.timer!.fire()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kGameOverSegue {
            let vc = segue.destination as! GameOverViewController
            vc.delegate = self
            vc.currentScore = levelsPassed
            vc.oldScore = Options.sharedOptions.score
            if levelsPassed > Options.sharedOptions.score {
                Options.sharedOptions.score = levelsPassed
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        shuffle()
    }
}

extension GameViewController: GameOverViewControllerDelegate {
    func gameOverViewControllerDidTapMenu() {
        navigationController?.popViewController(animated: true)
    }
    
    func gameOverViewControllerDidTapRestart() {
        level = 1
        startGame()
    }
}

extension UIViewController {
	func setupAdmobBanner(_ banner: GADBannerView) {
		GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [(kGADSimulatorID as! String)]
		
		//		#if DEBUG
//				banner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
		//		#else
		banner.adUnitID = "ca-app-pub-4053997895468335/5263744203"
		//		#endif
		banner.rootViewController = self
		
		banner.load(GADRequest())
		addBannerViewToView(banner)
	}
	
	func addBannerViewToView(_ bannerView: GADBannerView) {
		bannerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bannerView)
		view.addConstraints(
			[NSLayoutConstraint(item: bannerView,
								attribute: .top,
								relatedBy: .equal,
								toItem: topLayoutGuide,
								attribute: .top,
								multiplier: 1,
								constant: 0),
			 NSLayoutConstraint(item: bannerView,
								attribute: .centerX,
								relatedBy: .equal,
								toItem: view,
								attribute: .centerX,
								multiplier: 1,
								constant: 0)
		])
	}
}

