//
//  MUSitesMobileApp.swift
//  MUSitesMobile
//
//  Created by Katie Jackson on 2/13/24.
//

import SwiftUI
import FirebaseCore

@main
struct MUSitesMobileApp: App {
    @ObservedObject var router = AppRouter()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath) { // router is injected to navigation stack
                RootView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .inventorySitesList:
                            InventorySitesView()
                        case .detailedInventorySite(let inventorySite): DetailedInventorySiteView(inventorySite: inventorySite)
                        case .inventorySubmission(let inventorySite):
                            InventorySubmissionView(inventorySite: inventorySite)
                                .environmentObject(SheetManager())
                        case .inventoryChange(let inventorySite):
                            InventoryChangeView(inventorySite: inventorySite)
                        case .test: Text("Hello")
                        }
                    }
            }
            .environmentObject(router)
        }
    }
}

// Configure Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}
