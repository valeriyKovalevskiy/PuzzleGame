//
//  AppDelegate.swift

import UIKit
import UserNotifications
import FacebookCore
import FBSDKCoreKit.FBSDKAppEvents
import FBSDKCoreKit
import AppsFlyerLib
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		if launchOptions?[UIApplication.LaunchOptionsKey.url] == nil {
			fetchDeeplink()
		}
		setupAppsflyer()
		setupFirebase()
		setupAdmob()
		
		setupUserNotification(application: application)
		
		return true
	}
	
	func fetchDeeplink() {
		AppLinkUtility.fetchDeferredAppLink { (url, error) in
			if let url = url, url.query != nil  {
				print("\(url.absoluteString)")
				AdSettingsStorage.shared.deepParams = url.query
			} else {
				print("No deeplink")
			}
		}
	}
	
	// MARK: - Setup
	
	func setupAppsflyer() {
		AppsFlyerTracker.shared().appsFlyerDevKey = AdSettingsStorage.shared.appsFlayerDevKey
		AppsFlyerTracker.shared().appleAppID = kAppId
		AppsFlyerTracker.shared().delegate = self as AppsFlyerTrackerDelegate
		#if DEBUG
		AppsFlyerTracker.shared().isDebug = true
		#endif
		AdSettingsStorage.shared.appsflyerId = AppsFlyerTracker.shared().getAppsFlyerUID()
	}
	
	func setupFirebase() {
		FirebaseApp.configure()
		Messaging.messaging().delegate = self
	}
	
	func setupAdmob() {
		GADMobileAds.sharedInstance().start(completionHandler: nil)
	}
	
	func setupUserNotification(application: UIApplication) {
		// For iOS 10 display notification (sent via APNS)
		UNUserNotificationCenter.current().delegate = self
		
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: {_, _ in })
		
		application.registerForRemoteNotifications()
	}
	
	// MARK: - Application Delegate
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		if let rootViewController = self.window?.rootViewController {
			if rootViewController.isKind(of: UINavigationController.self) {
				return [.landscapeLeft, .landscapeRight]
			} else {
				return [.all]
			}
		} else {
			return [.landscapeLeft, .landscapeRight]
		}
	}
	
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		return ApplicationDelegate.shared.application(app, open: url, options: options)
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		print(token)
	}
	
	 func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
		
	}
		
	func applicationDidBecomeActive(_ application: UIApplication) {
		AppEvents.activateApp();
		AppsFlyerTracker.shared().trackAppLaunch()
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		completionHandler(true)
	}
}

extension AppDelegate : AppsFlyerTrackerDelegate {
	func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]!) {
		
	}
	
	func onConversionDataFail(_ error: Error!) {
		
	}
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								willPresent notification: UNNotification,
								withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([])
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter,
								didReceive response: UNNotificationResponse,
								withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		
		// Print full message.
		print(userInfo)
		completionHandler()
	}
}

extension AppDelegate : MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		print("Firebase registration token: \(fcmToken)")
		AdSettingsStorage.shared.pushToken = fcmToken
	}

	func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
		print("Received data message: \(remoteMessage.appData)")
	}
}

