//
//  GetDataOperation.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 29.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GetDataOperation: Operation {
    public enum State: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    // Operation overrides
    override open var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    override open func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
    
    open override func cancel() {
        super.cancel()
        state = .finished
    }
    
    private var method: String
    private var param: Parameters?
    var data: JSON?
    
    override func main() {
        VKService.shared.setCommand(self.method, param: self.param) { [weak self] response in
            switch response.result {
            case let .success(data):
                self?.data = JSON(data)
            case .failure(_):
                self?.data = nil
            }
            
            self?.state = .finished
        }
    }
    
    init (method: String, param: Parameters?){
        self.method = method
        self.param = param
    }
}
