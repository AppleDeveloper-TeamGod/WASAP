//
//  AppDelegate.swift
//  Wasap
//
//  Created by chongin on 10/3/24.
//

import UIKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

#if !DEBUG
        FirebaseApp.configure()
#endif
        CLLocationManager().requestWhenInUseAuthorization()

#if DEBUG
        /// 항상 첫 시작이라고 간주함. (온보딩 디버깅을 위해)
        /// 꼭 디버그 시에만 사용
//        UserDefaultsManager.shared.set(value: true, forKey: .isFirstLaunch)
#endif

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

