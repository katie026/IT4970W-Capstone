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
        // this function locates the view controller that's actively showing content on the screen at the moment
        
        // If a controller is provided as an argument, use that. Otherwise, start from the app's key window's root view controller
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        // keyWindow was deprecated, but it should be okay, since we don't have multiple scenes
        
        // If the initial controller is a UINavigationController, recursively call topViewController with its visibleViewController (the one currently displayed)
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        // If the controller is a UITabBarController, get its selectedViewController (the currently active tab and recursively call topViewController with the selected view controller
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // If the controller has a presentedViewController (a modal view controller on top), recursively call topViewController with the presented view controller
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        // if none of above conditions apply, return the current controller since it's the topmost one
        return controller
    }
}
