//
//  SettingViewController.swift

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var buttonArray: [UIButton]!
    
    override func viewDidLoad() {
        for btn in self.buttonArray {
            btn.isSelected = self.buttonArray.firstIndex(of: btn) == Options.sharedOptions.currentGameSettingsIndex
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func modeButtonTapped(_ sender: UIButton) {
        if Settings.shared.vibrationParams {
            HapticFeedback.trigger(.mediumImpact)
        }
		if sender.tag == 100 {
			if let index = buttonArray.firstIndex(of: sender) {
				Options.sharedOptions.currentGameSettingsIndex = index
				for btn in self.buttonArray {
					btn.isSelected = self.buttonArray.firstIndex(of: btn) == index
				}
			}
		} else {
			showAlert()
		}
    }
	
	func showAlert() {
		let alertController = UIAlertController(title: "This mode not availible in Free version", message: "To unlock this game mode. Buy \"2020\" version. Move to AppStore?", preferredStyle: .alert)
				
		let action1 = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
			if let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id1493543815?mt=8") {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}

		let action2 = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction) in
		}

		alertController.addAction(action1)
		alertController.addAction(action2)
		
		self.present(alertController, animated: true, completion: nil)
	}
}
