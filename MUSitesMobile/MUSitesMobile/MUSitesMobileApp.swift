//
//  MUSitesMobileApp.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/13/24.
//

import SwiftUI
import FirebaseCore

@main
struct MUSitesMobileApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AuthenticationView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Configured Firebase.")
        
        return true
    }
}
