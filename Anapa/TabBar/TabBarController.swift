//
//  TabBarController.swift
//  Anapa
//
//  Created by Сергей Майбродский on 15.09.2023.
//

import Foundation
import UIKit
import PanModal


class TabBarController: UITabBarController {

    override func viewDidLoad() {
      super.viewDidLoad()
      delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate  {
    internal func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false // Make sure you want this as false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.15, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
