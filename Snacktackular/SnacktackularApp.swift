//
//  SnacktackularApp.swift
//  Snacktackular
//
//  Created by Jeremy Taylor on 1/16/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SnacktackularApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var spotVM = SpotViewModel()
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(spotVM)
                .environmentObject(locationManager)
        }
    }
}
