//
//  UIApplicationExtension.swift
//  Sample
//
//  Created by Ankit Kumar on 17/02/21.
//

import UIKit
import Foundation


// MARK:- Private Extensions
public extension UIApplication {
    static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
         return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
         } else {
            return UIApplication.shared.delegate?.window ?? nil
         }
    }
}

public extension UIWindow {
    
    static var currentController: UIViewController? {
        return UIApplication.keyWindow?.currentController
    }
    
    var currentController: UIViewController? {
        if let vc = self.rootViewController {
            return topViewController(controller: vc)
        }
        return nil
    }
    
    func topViewController(controller: UIViewController? = UIApplication.keyWindow?.rootViewController) -> UIViewController? {
        if let nc = controller as? UINavigationController {
            if nc.viewControllers.count > 0 {
                return topViewController(controller: nc.viewControllers.last!)
            } else {
                return nc
            }
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
