//
//  Settings.swift

import UIKit

class Settings: NSObject {
    
    static let shared = Settings()
    
    var sound: Bool {
        set {
            UserDefaults.standard.set(!newValue, forKey: Constants.kGameSound.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return !UserDefaults.standard.bool(forKey: Constants.kGameSound.rawValue)
        }
    }
    
    var agreements: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.kSettingAgreements.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Constants.kSettingAgreements.rawValue)
        }
    }
    
    var timeUpdate: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.kSettingDeeplinkTimeout.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.integer(forKey: Constants.kSettingDeeplinkTimeout.rawValue)
        }
    }
    
    var  settingsParams: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.kSettingParams.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: Constants.kSettingParams.rawValue)
        }
    }
    
    var vibrationParams: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.kVibrationAvailable.rawValue)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: Constants.kVibrationAvailable.rawValue)
        }
    }
    
    private enum Constants: String {
        case kVibrationAvailable = "kVibrationAvailable"
        case kGameSound = "kGameSound"
        case kSettingAgreements = "kSettingAgreements"
        case kSettingParams = "kSettingParams"
        case kSettingDeeplinkTimeout = "kSettingDeeplinkTimeout"
    }
}

