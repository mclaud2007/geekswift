//
//  Animator.swift
//  weather
//
//  Created by Григорий Мартюшин on 23.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class CustomInteractTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted: Bool = false
    var shouldFinish: Bool = false
    
    var ViewController: UIViewController? {
        didSet {
            let edgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(catchEdgePenRecognizer(_:)))
            edgeRecognizer.edges = [.left]
            ViewController?.view.addGestureRecognizer(edgeRecognizer)
        }
    }
    
    @objc func catchEdgePenRecognizer(_ recognizer: UIScreenEdgePanGestureRecognizer){
        switch recognizer.state {
        case .began:
            self.hasStarted = true
            self.ViewController?.navigationController?.popViewController(animated: true)
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            let relTranslation = translation.x / (recognizer.view?.bounds.width ?? 1)
            let progress = max(0, min(1, relTranslation))
            self.shouldFinish = progress > 0.33
            self.update(progress)
        case .ended:
            self.hasStarted = false
            self.shouldFinish ? self.finish() : self.cancel()
        case .cancelled:
            self.hasStarted = false
            self.cancel()
        default: return
        }
    }
}

final class CutomTransitionAnimatorPush: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame = source.view.frame
        destination.view.transform = CGAffineTransform(translationX: source.view.frame.width, y: 0)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            destination.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { finish in
            if finish && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
            }
            
            transitionContext.completeTransition(finish && !transitionContext.transitionWasCancelled)
        }
    }
}

final class CutomTransitionAnimatorPop: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame = source.view.frame
        destination.view.transform = CGAffineTransform(translationX: -source.view.frame.width, y: 0)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            destination.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { finish in
            if finish && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
            }
            
            transitionContext.completeTransition(finish && !transitionContext.transitionWasCancelled)
        }
    }
}
