//
//  Shared.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import CallbackURLKit

enum DemoError: FailureCallbackError {
    case noText
    
    var code: Int {
        switch self {
        case .noText: return 0
        }
    }
    var message: String {
        switch self {
        case .noText: return "You must defined text parameters"
        }
    }
}

open class CallbackURLKitDemo: Client {
    
    open static let instance = CallbackURLKitDemo()
    
    public init() {
        super.init(urlScheme: "callbackurlkit")
    }
    
    open func printMessage(_ message: String, onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
        let parameters = ["text": message]
        try self.perform(action: CallbackURLKitDemo.PrintActionString, parameters: parameters,
                               onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }
    
    open static let PrintActionString = "print"
    open static let PrintAction: ActionHandler = { parameters, success, failed, cancel in
        if let text = parameters["text"] {
            print(text)
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .medium
            
            let dateString = formatter.string(from: Date())
            success(["text": text, "date": dateString])
        } else {
            failed(DemoError.noText)
        }
    }
    
}
