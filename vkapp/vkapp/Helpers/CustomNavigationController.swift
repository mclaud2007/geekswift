//
//  CustomNavigationController.swift
//  weather
//
//  Created by Григорий Мартюшин on 23.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class CustomNavControll: UINavigationController, UINavigationControllerDelegate {
    let interactTransition = CustomInteractTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactTransition.hasStarted ? interactTransition : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            self.interactTransition.ViewController = toVC
            return CutomTransitionAnimatorPop()
            
        } else if operation == .pop {
            if navigationController.viewControllers.first != toVC {
                self.interactTransition.ViewController = toVC
            }
        
            return CutomTransitionAnimatorPush()
            
        } else if operation == .none {
            return nil
        } else {
            return nil
        }
    }
}
