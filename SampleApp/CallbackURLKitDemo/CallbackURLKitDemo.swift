//
//  Shared.swift
//  CallbackURLKitDemo
//
//  Created by phimage on 03/01/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import Foundation
import CallbackURLKit

enum DemoErrorType: FailureCallbackErrorType {
    case NoText
    
    var code: Int {
        switch self {
        case .NoText: return 0
        }
    }
    var message: String {
        switch self {
        case .NoText: return "You must defined text parameters"
        }
    }
}

public class CallbackURLKitDemo: Client {
    
    public static let instance = CallbackURLKitDemo()
    
    public init() {
        super.init(URLScheme: "callbackurlkit")
    }
    
    public func printMessage(message: String, onSuccess: SuccessCallback? = nil, onFailure: FailureCallback? = nil, onCancel: CancelCallback? = nil) throws {
        let parameters = ["text": message]
        try self.performAction(CallbackURLKitDemo.PrintActionString, parameters: parameters,
                               onSuccess: onSuccess, onFailure: onFailure, onCancel: onCancel)
    }
    
    public static let PrintActionString = "print"
    public static let PrintAction: ActionHandler = { parameters, success, failed, cancel in
        if let text = parameters["text"] {
            print(text)
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = .MediumStyle
            
            let dateString = formatter.stringFromDate(NSDate())
            success(["text": text, "date": dateString])
        } else {
            failed(DemoErrorType.NoText)
        }
    }
    
}
