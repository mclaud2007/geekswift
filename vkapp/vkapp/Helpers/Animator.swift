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
            let edgeRecognizerLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(catchEdgePenRecognizer(_:)))
            edgeRecognizerLeft.edges = .left
            ViewController?.view.addGestureRecognizer(edgeRecognizerLeft)
            
            let edgeRecognizerRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(catchEdgePenRecognizer(_:)))
            edgeRecognizerRight.edges = .right
            ViewController?.view.addGestureRecognizer(edgeRecognizerRight)
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

class CutomTransitionAnimatorPush: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        destination.view.frame = source.view.frame
        destination.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: source.view.frame.width, y: 0))
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            destination.view.transform = CGAffineTransform(scaleX: 1, y: 1).concatenating(CGAffineTransform(translationX: 0, y: 0)) })
        { finish in
            if finish && !transitionContext.transitionWasCancelled {
                source.view.transform = .identity
            }
            
            // Переход отменен - надо откатить трансформацию назначения
            if transitionContext.transitionWasCancelled {
                source.view.transform = .identity
                destination.view.transform = .identity
            }
            
            transitionContext.completeTransition(finish && !transitionContext.transitionWasCancelled)
        }
    }
}

final class CutomTransitionAnimatorPop2Bottom: NSObject, UIViewControllerAnimatedTransitioning {
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
            
            // Переход отменен - надо откатить трансформацию назначения
            if transitionContext.transitionWasCancelled {
                source.view.transform = .identity
                destination.view.transform = .identity
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
            
            // Переход отменен - надо откатить трансформацию назначения
            if transitionContext.transitionWasCancelled {
                source.view.transform = .identity
                destination.view.transform = .identity
            }
            
            transitionContext.completeTransition(finish && !transitionContext.transitionWasCancelled)
        }
    }
}
