//
//  Utilities.swift
//  MUSitesMobile
//
//  Created by J Kim on 2/14/24.
//

import Foundation
import UIKit

final class Utilities {
    static let shared = Utilities ()
    private init() { }
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        // If a controller is provided as an argument, use that. Otherwise, start from the app's key window's root view controller
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
