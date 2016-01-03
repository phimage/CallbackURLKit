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